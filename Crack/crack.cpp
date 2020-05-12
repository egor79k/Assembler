#include <SFML/Graphics.hpp>

using namespace sf;

int main ()
{
	float length = 0;
	RenderWindow window (VideoMode (400, 200), "Crack V.2");
	RectangleShape progress_bar (Vector2f (120.f, 50.f));

	while (window.isOpen ())
	{
		Event event;
		while (window.pollEvent (event))
		{
			if (event.type == Event::Closed) window.close ();
		}

		window.clear (Color::Black);
		window.display ();

		progress_bar.setSize (Vector2f (length++, 25.f));
		if (length > 170.f) length = 0;

		window.draw (progress_bar);
	}
	return 0;
}