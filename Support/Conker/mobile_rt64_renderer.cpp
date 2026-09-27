#include <atomic>
#include <cstdio>
#include <memory>

#include "hle/rt64_application.h"
#include "ultramodern/renderer_context.hpp"

namespace {
uint8_t dmem[0x1000]{};
uint8_t imem[0x1000]{};
uint8_t rom_header[0x40]{};
uint32_t mi_intr{};
uint32_t dpc_regs[9]{};
std::atomic<uint32_t> display_lists{};

void check_interrupts() {}

class MobileRT64Renderer final : public ultramodern::renderer::RendererContext {
public:
    MobileRT64Renderer(uint8_t *rdram, ultramodern::renderer::WindowHandle window) {
        chosen_api = ultramodern::renderer::GraphicsApi::Metal;
        setup_result = ultramodern::renderer::SetupResult::GraphicsDeviceNotFound;
        if (!window.window || !window.view) {
            std::fputs("[mobile RT64] UIKit Metal surface is missing\n", stderr);
            return;
        }

        RT64::Application::Core core{};
        core.window.window = window.window;
        core.window.view = window.view;
        core.checkInterrupts = check_interrupts;
        core.HEADER = rom_header;
        core.RDRAM = rdram;
        core.DMEM = dmem;
        core.IMEM = imem;
        core.MI_INTR_REG = &mi_intr;
        core.DPC_START_REG = &dpc_regs[0];
        core.DPC_END_REG = &dpc_regs[1];
        core.DPC_CURRENT_REG = &dpc_regs[2];
        core.DPC_STATUS_REG = &dpc_regs[3];
        core.DPC_CLOCK_REG = &dpc_regs[4];
        core.DPC_BUFBUSY_REG = &dpc_regs[5];
        core.DPC_PIPEBUSY_REG = &dpc_regs[6];
        core.DPC_TMEM_REG = &dpc_regs[7];

        auto *vi = ultramodern::renderer::get_vi_regs();
        core.VI_STATUS_REG = &vi->VI_STATUS_REG;
        core.VI_ORIGIN_REG = &vi->VI_ORIGIN_REG;
        core.VI_WIDTH_REG = &vi->VI_WIDTH_REG;
        core.VI_INTR_REG = &vi->VI_INTR_REG;
        core.VI_V_CURRENT_LINE_REG = &vi->VI_V_CURRENT_LINE_REG;
        core.VI_TIMING_REG = &vi->VI_TIMING_REG;
        core.VI_V_SYNC_REG = &vi->VI_V_SYNC_REG;
        core.VI_H_SYNC_REG = &vi->VI_H_SYNC_REG;
        core.VI_LEAP_REG = &vi->VI_LEAP_REG;
        core.VI_H_START_REG = &vi->VI_H_START_REG;
        core.VI_V_START_REG = &vi->VI_V_START_REG;
        core.VI_V_BURST_REG = &vi->VI_V_BURST_REG;
        core.VI_X_SCALE_REG = &vi->VI_X_SCALE_REG;
        core.VI_Y_SCALE_REG = &vi->VI_Y_SCALE_REG;

        RT64::ApplicationConfiguration config{};
        config.detectDataPath = false;
        config.useConfigurationFile = false;
        app = std::make_unique<RT64::Application>(core, config);
        app->userConfig.graphicsAPI = RT64::UserConfiguration::GraphicsAPI::Metal;
        app->enhancementConfig.f3dex.forceBranch = true;
        app->enhancementConfig.textureLOD.scale = true;
        const auto result = app->setup(0);
        if (result != RT64::Application::SetupResult::Success) {
            std::fprintf(stderr, "[mobile RT64] setup failed: %d\n", int(result));
            app.reset();
            return;
        }
        setup_result = ultramodern::renderer::SetupResult::Success;
        std::fputs("[mobile RT64] game renderer initialized\n", stdout);
    }

    bool valid() override { return app != nullptr; }
    bool update_config(const ultramodern::renderer::GraphicsConfig &,
                       const ultramodern::renderer::GraphicsConfig &) override { return true; }
    void enable_instant_present() override {
        app->enhancementConfig.presentation.mode =
            RT64::EnhancementConfiguration::Presentation::Mode::PresentEarly;
        app->updateEnhancementConfig();
    }
    void send_dl(const OSTask *task) override {
        app->state->rsp->reset();
        app->interpreter->loadUCodeGBI(task->t.ucode & 0x3FFFFFF,
                                        task->t.ucode_data & 0x3FFFFFF, true);
        app->processDisplayLists(app->core.RDRAM, task->t.data_ptr & 0x3FFFFFF, 0, true);
        const auto count = ++display_lists;
        if (count <= 3 || count % 60 == 0) {
            std::printf("[mobile RT64] display list #%u\n", count);
        }
    }
    void send_dummy_workload(uint32_t fb_address) override {
        app->state->listProcessBegin();
        app->state->rdp->setColorImage(G_IM_FMT_RGBA, G_IM_SIZ_16b, 320, fb_address);
        app->state->rdp->setOtherMode(0x382C30, 0);
        app->state->rdp->fillRect(0, 0, 320 << 2, 240 << 2);
        app->state->fullSync();
        app->state->listProcessEnd();
    }
    void update_screen() override { app->updateScreen(); }
    void shutdown() override { if (app) app->end(); }
    uint32_t get_display_framerate() const override { return 60; }
    float get_resolution_scale() const override { return 1.0f; }

private:
    std::unique_ptr<RT64::Application> app;
};
}

std::unique_ptr<ultramodern::renderer::RendererContext> squirrelpad_create_mobile_renderer(
    uint8_t *rdram, ultramodern::renderer::WindowHandle window, bool) {
    return std::make_unique<MobileRT64Renderer>(rdram, window);
}
