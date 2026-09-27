#include "plume_render_interface.h"

#include <memory>
#include <string>

namespace plume {
    std::unique_ptr<RenderInterface> CreateMetalInterface();
}

namespace {
    struct MetalContext {
        std::unique_ptr<plume::RenderInterface> renderInterface;
        std::unique_ptr<plume::RenderDevice> device;
        std::unique_ptr<plume::RenderCommandQueue> commandQueue;
        std::unique_ptr<plume::RenderSwapChain> swapChain;
        std::string status;
    };

    std::unique_ptr<MetalContext> context;
    void *surface_window = nullptr;
    void *surface_view = nullptr;
}

extern "C" const char *squirrelpad_rt64_initialize(void *window, void *view) {
    if ((window == nullptr) || (view == nullptr)) {
        return nullptr;
    }

    auto candidate = std::make_unique<MetalContext>();
    candidate->renderInterface = plume::CreateMetalInterface();
    if (candidate->renderInterface == nullptr) {
        return nullptr;
    }

    candidate->device = candidate->renderInterface->createDevice();
    if (candidate->device == nullptr) {
        return nullptr;
    }

    candidate->commandQueue = candidate->device->createCommandQueue(
        plume::RenderCommandListType::DIRECT
    );
    if (candidate->commandQueue == nullptr) {
        return nullptr;
    }

    const plume::RenderWindow renderWindow = {window, view};
    candidate->swapChain = candidate->commandQueue->createSwapChain(
        plume::RenderSwapChainDesc(
            renderWindow,
            plume::RenderFormat::B8G8R8A8_UNORM,
            3
        )
    );
    if ((candidate->swapChain == nullptr) || !candidate->swapChain->resize()) {
        return nullptr;
    }

    candidate->status = "renderer: RT64 Metal "
        + candidate->device->getDescription().name
        + " " + std::to_string(candidate->swapChain->getWidth())
        + "x" + std::to_string(candidate->swapChain->getHeight());
    context = std::move(candidate);
    surface_window = window;
    surface_view = view;
    return context->status.c_str();
}

extern "C" void squirrelpad_rt64_release_probe() {
    // RT64's game renderer creates its own swapchain on this same layer.
    context.reset();
}

extern "C" void squirrelpad_mobile_window(void **window, void **view) {
    *window = surface_window;
    *view = surface_view;
}

extern "C" void squirrelpad_rt64_shutdown() {
    context.reset();
    surface_window = nullptr;
    surface_view = nullptr;
}
