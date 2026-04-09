#include <iostream>
#include <memory>
#include <vector>
#include <SDL.h>
#include <SDL_ttf.h>
#include "Vmips_top.h"
#include "verilated.h"

// Screen configuration
const int SCREEN_COLS = 80;
const int SCREEN_ROWS = 25;
const int CELL_WIDTH  = 10; // Pixels per character
const int CELL_HEIGHT = 20;

struct ScreenBuffer {
    char data[SCREEN_ROWS][SCREEN_COLS];
    bool dirty;
    
    ScreenBuffer() {
        clear();
    }
    
    void clear() {
        for (int r = 0; r < SCREEN_ROWS; r++) {
            for (int c = 0; c < SCREEN_COLS; c++) {
                data[r][c] = ' ';
            }
        }
        dirty = true;
    }
};

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    auto top = std::make_unique<Vmips_top>();

    // Initialize SDL2
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        std::cerr << "SDL could not initialize! SDL_Error: " << SDL_GetError() << std::endl;
        return 1;
    }
    if (TTF_Init() == -1) {
        std::cerr << "TTF could not initialize! TTF_Error: " << TTF_GetError() << std::endl;
        return 1;
    }

    SDL_Window* window = SDL_CreateWindow(
        "double-l32 MIPS Emulator",
        SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
        SCREEN_COLS * CELL_WIDTH, SCREEN_ROWS * CELL_HEIGHT,
        SDL_WINDOW_SHOWN
    );

    SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
    TTF_Font* font = TTF_OpenFont("assets/font.ttf", 16);
    if (!font) {
        std::cerr << "Failed to load font! Make sure assets/font.ttf exists." << std::endl;
        return 1;
    }

    ScreenBuffer screen;

    // Emulator init
    top->clk_i = 0;
    top->rst_ni = 0; // Assert reset
    top->mmio_keys_i = 0;

    bool quit = false;
    SDL_Event e;
    vluint64_t clock_cycles = 0;

    std::cout << "Starting simulation with SDL2 UI..." << std::endl;

    while (!quit && !Verilated::gotFinish() && clock_cycles < 1000000000) {
        // Handle UI events periodically
        if (clock_cycles % 1000 == 0) {
            while (SDL_PollEvent(&e) != 0) {
                if (e.type == SDL_QUIT) {
                    quit = true;
                } else if (e.type == SDL_KEYDOWN) {
                    // Map keys to ASCII if possible for the keyboard buffer
                    if (e.key.keysym.sym < 128) {
                        top->mmio_keys_i = (uint32_t)e.key.keysym.sym;
                    }
                } else if (e.type == SDL_KEYUP) {
                    top->mmio_keys_i = 0;
                }
            }
        }

        // Hardware Clock Toggle (Rising Edge)
        top->clk_i = 1;
        top->eval();

        // Check for MMIO Screen Write
        if (top->mmio_screen_we_o) {
            if (top->mmio_screen_addr_o == 0x10002000) {
                std::cout << "Hardware requested halt (Write to 0x10002000)." << std::endl;
                quit = true;
            } else if (top->mmio_screen_addr_o >= 0x10000000 && top->mmio_screen_addr_o < 0x10001000) {
                // Address is absolute (e.g., 0x10000004). We offset to 0.
                uint32_t offset = top->mmio_screen_addr_o - 0x10000000;
                // Byte address to character index
                uint32_t index = offset / 4; 
                
                if (index < (SCREEN_COLS * SCREEN_ROWS)) {
                    int row = index / SCREEN_COLS;
                    int col = index % SCREEN_COLS;
                    char c = (char)(top->mmio_screen_wdata_o & 0xFF);
                    if (screen.data[row][col] != c) {
                        screen.data[row][col] = c;
                        screen.dirty = true;
                        std::cout << "SCREEN WRITE @ 0x" << std::hex << top->mmio_screen_addr_o 
                                  << " : '" << c << "'" << std::dec << std::endl;
                    }
                }
            }
        }

        // Hardware Clock Toggle (Falling Edge)
        top->clk_i = 0;
        top->eval();

        if (clock_cycles == 5) {
            top->rst_ni = 1; // Release reset
        }

        // Render Frame
        // Rendering every hardware clock is too slow. We cap it to ~60FPS.
        // Assuming this loop runs very fast, we use a crude cycle modulo to render.
        if (clock_cycles % 10000 == 0 && screen.dirty) {
            SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255); // Black background
            SDL_RenderClear(renderer);

            SDL_Color textColor = { 50, 255, 50, 255 }; // Phosphor Green

            for (int r = 0; r < SCREEN_ROWS; r++) {
                // To keep it fast, we can render row by row as strings, or char by char.
                // Char by char is easier for exact grid alignment.
                for (int c = 0; c < SCREEN_COLS; c++) {
                    char ch = screen.data[r][c];
                    if (ch != ' ') {
                        // Inefficient to render char-by-char creating textures every frame,
                        // but acceptable for MVP.
                        char str[2] = {ch, '\0'};
                        SDL_Surface* surface = TTF_RenderText_Solid(font, str, textColor);
                        if (surface) {
                            SDL_Texture* texture = SDL_CreateTextureFromSurface(renderer, surface);
                            SDL_Rect dest = {c * CELL_WIDTH, r * CELL_HEIGHT, surface->w, surface->h};
                            SDL_RenderCopy(renderer, texture, NULL, &dest);
                            SDL_DestroyTexture(texture);
                            SDL_FreeSurface(surface);
                        }
                    }
                }
            }

            SDL_RenderPresent(renderer);
            screen.dirty = false;
        }

        clock_cycles++;
    }

    std::cout << "Simulation completed (" << clock_cycles << " cycles)." << std::endl;

    TTF_CloseFont(font);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    TTF_Quit();
    SDL_Quit();

    top->final();
    return 0;
}
