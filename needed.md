# Math and misc
x cos(f x)
x sin(f x)
angle_fix(f x)     # sets x between (0 and 2 pi)
x prng()             # pseudo random generator

# Player
~ p_move()           # includes wraping around edges
x p_draw()           # draws the player
shoot()            # shoots a bullet (nf)

# Asteroids

a_init()           # initialized asteroid with random values and adds to list
a_remove(int id)   # removes asteroid from the list (the IDs for other asteroids will change)
a_destroy()        # Destroys asteroid (might split into smaller ones)
x a_draw(int64* a)   # Draws asteroid at address a
x a_move(int64* a)   # (nf)
a_outside(int64* a)# (nf)
a_collision(int64 *a,
	int x, int y)  # checks if asteroid a collides with point (x,y)

struct asteroid {
	f x, y;
	f vx, vy;
	f angle, va;
	byte t, s;
} = 32 bytes

# Bullet
b_init(f x, f y, f a) #initialized a bullet at point (x,y) with angle a
b_move(* b)        # Moves bullet b
b_remove(* b)      # Removes bullet b
b_draw(* b)        # Draws bullet b



# Game stuff
One function for game logic


Maybe add menu, name, score and more!!! (after we have the playable demo)
