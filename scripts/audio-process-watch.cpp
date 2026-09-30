// Read-only macOS process telemetry for correlating audio failures.
// Usage: audio-process-watch <pid> <seconds>; JSON Lines on stdout.
#include <libproc.h>
#include <mach/mach_time.h>
#include <sys/proc_info.h>
#include <chrono>
#include <thread>
#include <cstdio>
#include <charconv>
#include <cstring>
int main(int argc,char** argv) {
    if(argc!=3){std::fprintf(stderr,"usage: audio-process-watch <pid> <seconds>\n");return 2;}
    int pid=0, seconds=0;
    const auto parse=[](const char* arg,int& value) {
        const auto end=arg+std::strlen(arg);
        const auto result=std::from_chars(arg,end,value);
        return result.ec==std::errc{} && result.ptr==end;
    };
    if(!parse(argv[1],pid) || !parse(argv[2],seconds))return 2;
    if(pid<=0 || seconds<=0 || seconds>1800)return 2;
    mach_timebase_info_data_t timebase{};
    if(mach_timebase_info(&timebase)!=KERN_SUCCESS || !timebase.denom)return 1;
    const auto ns=[&](uint64_t ticks) { return static_cast<uint64_t>(static_cast<__uint128_t>(ticks)*timebase.numer/timebase.denom); };
    uint64_t start_seconds=0, start_microseconds=0;
    const auto end=std::chrono::steady_clock::now()+std::chrono::seconds(seconds);
    while(std::chrono::steady_clock::now()<end) {
        proc_taskallinfo i{};
        int n=proc_pidinfo(pid,PROC_PIDTASKALLINFO,0,&i,sizeof(i));
        if(n!=sizeof(i)){std::fprintf(stderr,"proc_pidinfo pid=%d bytes=%d expected=%zu\n",pid,n,sizeof(i));return 1;}
        if(start_seconds && (start_seconds!=i.pbsd.pbi_start_tvsec || start_microseconds!=i.pbsd.pbi_start_tvusec)) {
            std::fprintf(stderr,"pid=%d was reused; stopping\n",pid);return 1;
        }
        start_seconds=i.pbsd.pbi_start_tvsec;start_microseconds=i.pbsd.pbi_start_tvusec;
        const auto ms=std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::steady_clock::now().time_since_epoch()).count();
        std::printf("{\"at_ms\":%lld,\"pid\":%d,\"flags\":%u,\"user_ns\":%llu,\"system_ns\":%llu,\"faults\":%d,\"pageins\":%d,\"csw\":%d,\"resident\":%llu}\n",(long long)ms,pid,i.pbsd.pbi_flags,(unsigned long long)ns(i.ptinfo.pti_total_user),(unsigned long long)ns(i.ptinfo.pti_total_system),i.ptinfo.pti_faults,i.ptinfo.pti_pageins,i.ptinfo.pti_csw,(unsigned long long)i.ptinfo.pti_resident_size);
        std::fflush(stdout);
        std::this_thread::sleep_for(std::chrono::milliseconds(200));
    }
}
