#include <stdio.h>
#include <unistd.h>

#define END1 	printf("\x1b[31m\n\tError: wrong file!\n\x1b[30m\n\tPress F to end program...\n");	\
				WAIT																			\
				printf("\x1b[0m\e[1;1H\e[2J\n");													\
				return 0;						 													\

#define CIRCLE(x) 	printf (x);				\
					fflush (stdout);		\
					usleep (500000);		\

#define WAIT	printf("\n\tPress any key to continue...\n");	\
				getchar ();										\

#define DUCK	"\U0001F986"

#define COMPLETE printf("\x1b[31m\n\tComplete! %s\n\x1b[30m", DUCK);


const char crack_1[] = "//==\\\\  ||=\\\\     //\\\\     //==\\\\  || //        //==\\\\    //==\\\\";
const char crack_2[] = "||      ||=//    //  \\\\    ||      ||//             //    ||  ||";
const char crack_3[] = "||      ||\\\\    //====\\\\   ||      ||\\\\           //      ||  ||";
const char crack_4[] = "\\\\==//  || \\\\  //      \\\\  \\\\==//  || \\\\        //==== [] \\\\==//";
const char  file_name[] = "to_egor";
const int   file_size   = 768;
const int   file_hash   = 26179;
const int   jump_pos    = 286;
const short new_jump    = 0x43eb;


void ProgressCircle ()
{
	CIRCLE ("\U000025CB");
	CIRCLE ("\b\U000025D4");
	CIRCLE ("\b\U000025D1");
	CIRCLE ("\b\U000025D5");
	CIRCLE ("\b\U000025Cf");
	return;
}


void ProgressBar ()
{
	for (int i = 0; i <= 100; i += 2)
	{
		printf("%s%2d%% %s", u8"\U00002588", i, DUCK);
		usleep(200000);
		fflush(stdout);
		printf("\b\b\b\b\b\b");
	}
	return;
}


int main ()
{
	printf("\x1b[1;31;47m\e[1;1H\e[2J\n");
	printf("\t\t\t%s\n\t\t\t%s\n\t\t\t%s\n\t\t\t%s\n", crack_1, crack_2, crack_3, crack_4);
	printf("\n\n\tWelcome to the Crack 2.0 %s\n\x1b[30m", DUCK);
	WAIT

	char buffer[file_size] = {};
	int hash_summ = 0;

	FILE *executable = fopen (file_name, "rb+");

	printf("\n\tFile size checking ");
	ProgressCircle ();

	fseek (executable, 0, SEEK_END);							//Check file size
	if (ftell (executable) != file_size)
	{
		END1
	}

	COMPLETE
	WAIT


	printf("\n\tFile hash checking ");
	ProgressCircle ();

	fseek (executable, 0, SEEK_SET);							//Check file hash
	fread (buffer, sizeof (char), file_size, executable);

	for (int i = 0; i < file_size; ++i)
	{
		hash_summ += buffer[i];
		hash_summ = hash_summ xor 1111111111;
	}

	if (hash_summ != file_hash)
	{
		END1
	}

	COMPLETE
	WAIT

	printf ("\t%s: Are you ready???", DUCK);
	getchar ();
	printf ("\tYou: \U0001F425 Yes!\n");
	usleep (800000);
	printf ("\t%s: I can't hear you?!", DUCK);
	getchar ();
	printf ("\tYou: \U0001F425 Yes!!!\n");
	usleep (800000);
	printf ("\t%s: Ok. Take your hands away from the keyboard! Professional is working!\n\n\t", DUCK);
	usleep (800000);
	ProgressBar ();
	printf("\n");
	fseek (executable, 286, SEEK_SET);
	fwrite (&new_jump, sizeof (short), 1, executable);

	fclose (executable);

	COMPLETE

	WAIT

	printf("\x1b[0m\e[1;1H\e[2J\n");
	return 0;
}