#include <stdio.h>
#include <string.h>
#include <unistd.h>

int main ()
{
	const char start_pswd_seed[] = "CrackPswd";		//It must be 9 symbols!!!
	const char middl_pswd_seed[] = "hstrtab";		//Symbol in hash str before 0
	const char middle_symbols [] = "000";			//Empty place filler 3 symbols
	const int start_pswd_seed_len = 9;
	const int middl_pswd_seed_len = 7;
	const int hash_xor_val = 0x72816354;

	char new_hash_str[30] = {};
	strcpy (new_hash_str, start_pswd_seed);
	strcpy (&new_hash_str[10], middl_pswd_seed);
	strcpy (&new_hash_str[17], middle_symbols);
	strcpy (&new_hash_str[20], start_pswd_seed);

	const char old_hash_str[] = "asm-ok";			//Hash sample
	const int old_hash_str_len = 6;
	int result = 0;
	int rbx = 0;
	int i = 0;

	for (i = 0; i < old_hash_str_len; ++i)
	{
		rbx = rbx xor hash_xor_val;
		rbx += old_hash_str[i];
	}
	
	int hash_must_be = rbx & 0xff;
	printf("Hash must be: %x\n", hash_must_be);


	rbx = 0;

	for (i = 0; i < start_pswd_seed_len; ++i)		//Start hash counting...
	{
		rbx = rbx xor hash_xor_val;
		rbx += new_hash_str[i];
	}

	printf("Start pswd with %s and hash %x\n", start_pswd_seed, rbx);


	rbx = rbx xor hash_xor_val;
	int new_hash = rbx;

	for (int symb = 0; symb < 128; ++symb)			//Selecting symbol
	{
		rbx = new_hash;
		rbx += symb;

		for (i = 0; i < middl_pswd_seed_len; ++i)	//Check if hash is appropriate
		{
			rbx = rbx xor hash_xor_val;
			rbx += middl_pswd_seed[i];
		}

		rbx &= 0xff;
		if (rbx == hash_must_be) result = symb;
	}
	printf("Last symb must be: %x = '%c'\n", result, result);

	printf("\n\x1b[32;1mGenerating new password...\n");
	for (i = 0; i <= 100; i += 5)					//Progress bar
	{
		printf("%s%2d%%", u8"\U00002588", i);
		usleep(300000);
		fflush(stdout);
		printf("\b\b\b");
	}


	new_hash_str[9] = result;
	new_hash_str[29] = result;
	printf("\n\nYour new password: \x1b[0m%s\n\n", new_hash_str);
	return 0;
}