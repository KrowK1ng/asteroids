#include "raylib.h"

static RenderTexture2D T;

void
helpStart(int w, int h) {
	T = LoadRenderTexture(w,h);
}


void
helpRender() {
	BeginTextureMode(T);
}

void
helpPresent(int w, int h) {
	DrawTexturePro(T.texture, (Rectangle){0.0, 0.0, (float)w, (float)-h},
			(Rectangle){0.0, 0.0, GetScreenWidth(), GetScreenHeight()}, 
			(Vector2) {0.0, 0.0},
			0.0, WHITE);
}
