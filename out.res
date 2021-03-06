/bin/ls
a.out
microshell
microshell.c
microshell.dSYM
out.res
subject.en.txt
subject.fr.txt
test.sh

/bin/cat microshell.c
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <unistd.h>
#define PIPE 1
#define BREAK 2
#define ARG 3
#define CD 4

int		tabsize(char **tab)
{
	int i = 0;
	while (tab[i])
		i++;
	return i;
}

void	ft_putstr(char *s)
{
	while (*s)
		write(2, s++, 1);
}

size_t	ft_strlen(char *s)
{
	size_t i = 0;
	while (s[i])
		i++;
	return (i);
}

char	*ft_strdup(char *src)
{
	int i = -1;
	char *dst = NULL;
	dst = malloc(sizeof(char) * (ft_strlen(src) + 1));
	while (src[++i])
		dst[i] = src[i];
	dst[i] = '\0';
	return dst;
}

int		ft_type(char *av)
{
	if (!av)
		return (-1);
	if (strcmp(av, "|") == 0)
		return PIPE;
	else if (strcmp(av, ";") == 0)
		return BREAK;
	else if (strcmp(av, "cd") == 0)
		return CD;
	return ARG;
}

void	printtab(char **cmd)
{
	for (size_t i = 0; cmd[i]; i++)
	{
		printf("<{%s}>", cmd[i]);
	}
}

void	ft_chdir(char **cmd)
{
	if (!cmd[1] || cmd[2])
	{
		ft_putstr("error: cd: bad arguments\n");
		return ;
	}
	if (chdir(cmd[1]) == -1)
	{
		ft_putstr("error: cd: cannot change directory to ");
		ft_putstr(cmd[1]);
		ft_putstr("\n");
		return ;
	}
}

void	pipeline(char ***cmd, char **env, int *type)
{
	(void)env;
	(void)type;
	int index = 0;
	int pfd[2];
	pid_t pid;
	while (*cmd)
	{
		if (ft_type((*cmd)[0]) == CD)
		{
			ft_chdir(*cmd);
		}
		else
		{
			if ((*cmd)[0] != NULL)
			{
				if (pipe(pfd) == -1)
				{
					ft_putstr("error: fatal\n");
					exit(1);
				}
				pid = fork();
				if (pid == -1)
				{
					ft_putstr("error: fatal\n");
					exit(1);
				}
				else if (pid == 0)
				{
					if (*(cmd + 1) && type[index] == PIPE)
						dup2(pfd[1], 1);
					close(pfd[0]);
					close(pfd[1]);
					if (execve((*cmd)[0], &(*cmd)[0], env) == -1)
					{
						ft_putstr("error: cannot execute ");
						ft_putstr((*cmd)[0]);
						ft_putstr("\n");
					}
					exit(1);
				}
				else
				{
					if (type[index] == PIPE)
						dup2(pfd[0], 0);
					waitpid(pid,NULL,0);
					close(pfd[0]);
					close(pfd[1]);
				}
				index++;
			}
		}
		cmd++;
	}
}

int		main(int ac, char **av, char **env)
{
	(void)ac;
	(void)av;
	(void)env;
	int		i = 1;
	char	***cmd = NULL;
	int		*type = NULL;
	cmd = (char***)malloc(sizeof(char**) * 1500);
	type = (int*)malloc(sizeof(int) * 1500);
	for (size_t i = 0; i < 1500; i++) {
		cmd[i] = (char**)malloc(sizeof(char*) * 1500);
		for (size_t j = 0; j < 1500; j++) {
			cmd[i][j] = (char*)malloc(sizeof(char) * 1500);
		}
	}
	size_t cmdi = 0;
	size_t cmdj = 0;
	if (ac >= 2)
	{
		while (av[i])
		{
			while (av[i][0] == '\0')
				i++;
			if (ft_type(av[i]) == PIPE)
			{
				cmd[cmdi][cmdj] = 0;
				type[cmdi] = PIPE;
				cmdj = 0;
				cmdi++;
				i++;
			}
			else if (ft_type(av[i]) == BREAK)
			{
				cmd[cmdi][cmdj] = 0;
				type[cmdi] = BREAK;
				cmdj = 0;
				cmdi++;
				while (ft_type(av[i]) == BREAK)
					i++;
			}
			if (av[i] != NULL)
			{
				cmd[cmdi][cmdj] = av[i];
				type[cmdi] = ARG;
				cmdj++;
			}
			i++;
		}
		cmd[cmdi][cmdj] = NULL;
		cmd[cmdi + 1] = NULL;
		pipeline(cmd, env, type);
	}
	exit(0);
}

/bin/ls microshell.c
microshell.c

/bin/ls salut

;

; ;

; ; /bin/echo OK
OK

; ; /bin/echo OK ;
OK

; ; /bin/echo OK ; ;
OK

; ; /bin/echo OK ; ; ; /bin/echo OK
OK
OK

/bin/ls | /usr/bin/grep microshell
microshell
microshell.c
microshell.dSYM

/bin/ls | /usr/bin/grep microshell | /usr/bin/grep micro
microshell
microshell.c
microshell.dSYM

/bin/ls | /usr/bin/grep microshell | /usr/bin/grep micro | /usr/bin/grep shell | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro
microshell
microshell.c
microshell.dSYM

/bin/ls | /usr/bin/grep microshell | /usr/bin/grep micro | /usr/bin/grep shell | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep micro | /usr/bin/grep shell | /usr/bin/grep shell | /usr/bin/grep shell | /usr/bin/grep shell | /usr/bin/grep shell | /usr/bin/grep shell | /usr/bin/grep shell | /usr/bin/grep shell | /usr/bin/grep shell | /usr/bin/grep shell | /usr/bin/grep shell | /usr/bin/grep shell | /usr/bin/grep shell | /usr/bin/grep shell | /usr/bin/grep shell | /usr/bin/grep shell | /usr/bin/grep shell | /usr/bin/grep shell | /usr/bin/grep shell | /usr/bin/grep shell | /usr/bin/grep shell | /usr/bin/grep shell | /usr/bin/grep shell | /usr/bin/grep shell | /usr/bin/grep shell | /usr/bin/grep shell | /usr/bin/grep shell | /usr/bin/grep shell | /usr/bin/grep shell | /usr/bin/grep shell | /usr/bin/grep shell | /usr/bin/grep shell | /usr/bin/grep shell | /usr/bin/grep shell | /usr/bin/grep shell | /usr/bin/grep shell | /usr/bin/grep shell | /usr/bin/grep shell | /usr/bin/grep shell
microshell
microshell.c
microshell.dSYM

/bin/ls ewqew | /usr/bin/grep micro | /bin/cat -n ; /bin/echo dernier ; /bin/echo
dernier


/bin/ls | /usr/bin/grep micro | /bin/cat -n ; /bin/echo dernier ; /bin/echo ftest ;
     1	microshell
     2	microshell.c
     3	microshell.dSYM
dernier
ftest

/bin/echo ftest ; /bin/echo ftewerwerwerst ; /bin/echo werwerwer ; /bin/echo qweqweqweqew ; /bin/echo qwewqeqrtregrfyukui ;
ftest
ftewerwerwerst
werwerwer
qweqweqweqew
qwewqeqrtregrfyukui

/bin/ls ftest ; /bin/ls ; /bin/ls werwer ; /bin/ls microshell.c ; /bin/ls subject.fr.txt ;
a.out
leaks.res
microshell
microshell.c
microshell.dSYM
out.res
subject.en.txt
subject.fr.txt
test.sh
microshell.c
subject.fr.txt

/bin/ls | /usr/bin/grep micro ; /bin/ls | /usr/bin/grep micro ; /bin/ls | /usr/bin/grep micro ; /bin/ls | /usr/bin/grep micro ;
microshell
microshell.c
microshell.dSYM
microshell
microshell.c
microshell.dSYM
microshell
microshell.c
microshell.dSYM
microshell
microshell.c
microshell.dSYM

/bin/cat subject.fr.txt | /usr/bin/grep a | /usr/bin/grep b ; /bin/cat subject.fr.txt ;
Ecrire un programme qui aura ressemblera ?? un executeur de commande shell
- Les executables seront appel??s avec un chemin relatif ou absolut mais votre programme ne devra pas construire de chemin (en utilisant la variable d environment PATH par exemple)
- Votre programme doit implementer "|" et ";" comme dans bash
- Votre programme doit implementer la commande "built-in" cd et seulement avec un chemin en argument (pas de '-' ou sans argument)
	- si cd n'a pas le bon nombre d'argument votre programme devra afficher dans STDERR "error: cd: bad arguments" suivi d'un '\n'
- Votre programme n'a pas ?? gerer les variables d'environment ($BLA ...)
- Si execve echoue votre programme doit afficher dans STDERR "error: cannot execute executable_that_failed" suivi d'un '\n' en ayant remplac?? executable_that_failed avec le chemin du programme qui n'a pu etre execut?? (ca devrait etre le premier argument de execve)
- Votre programme devrait pouvoir accepter des centaines de "|" meme si la limite du nombre de "fichier ouvert" est inferieur ?? 30.
N'oubliez pas de passer les variables d'environment ?? execve
Assignment name  : microshell
Expected files   : *.c *.h
Allowed functions: malloc, free, write, close, fork, waitpid, signal, kill, exit, chdir, execve, dup, dup2, pipe, strcmp, strncmp
--------------------------------------------------------------------------------------

Ecrire un programme qui aura ressemblera ?? un executeur de commande shell
- La ligne de commande ?? executer sera passer en argument du programme
- Les executables seront appel??s avec un chemin relatif ou absolut mais votre programme ne devra pas construire de chemin (en utilisant la variable d environment PATH par exemple)
- Votre programme doit implementer "|" et ";" comme dans bash
	- Nous n'essaierons jamais un "|" imm??diatement suivi ou pr??c??d?? par rien ou un autre "|" ou un ";"
- Votre programme doit implementer la commande "built-in" cd et seulement avec un chemin en argument (pas de '-' ou sans argument)
	- si cd n'a pas le bon nombre d'argument votre programme devra afficher dans STDERR "error: cd: bad arguments" suivi d'un '\n'
	- si cd a echou?? votre programme devra afficher dans STDERR "error: cd: cannot change directory to path_to_change" suivi d'un '\n' avec path_to_change remplacer par l'argument ?? cd
	- une commande cd ne sera jamais imm??diatement pr??c??d??e ou suivie par un "|"
- Votre programme n'a pas ?? gerer les "wildcards" (*, ~ etc...)
- Votre programme n'a pas ?? gerer les variables d'environment ($BLA ...)
- Si un appel systeme, sauf execve et chdir, retourne une erreur votre programme devra imm??diatement afficher dans STDERR "error: fatal" suivi d'un '\n' et sortir
- Si execve echoue votre programme doit afficher dans STDERR "error: cannot execute executable_that_failed" suivi d'un '\n' en ayant remplac?? executable_that_failed avec le chemin du programme qui n'a pu etre execut?? (ca devrait etre le premier argument de execve)
- Votre programme devrait pouvoir accepter des centaines de "|" meme si la limite du nombre de "fichier ouvert" est inferieur ?? 30.

Par exemple, la commande suivante doit marcher:
$>./microshell /bin/ls "|" /usr/bin/grep microshell ";" /bin/echo i love my microshell
microshell
i love my microshell
$>

Conseils:
N'oubliez pas de passer les variables d'environment ?? execve

Conseils:
Ne fuitez pas de file descriptor!
/bin/cat subject.fr.txt | /usr/bin/grep a | /usr/bin/grep w ; /bin/cat subject.fr.txt ;
Allowed functions: malloc, free, write, close, fork, waitpid, signal, kill, exit, chdir, execve, dup, dup2, pipe, strcmp, strncmp
- Votre programme n'a pas ?? gerer les "wildcards" (*, ~ etc...)
Assignment name  : microshell
Expected files   : *.c *.h
Allowed functions: malloc, free, write, close, fork, waitpid, signal, kill, exit, chdir, execve, dup, dup2, pipe, strcmp, strncmp
--------------------------------------------------------------------------------------

Ecrire un programme qui aura ressemblera ?? un executeur de commande shell
- La ligne de commande ?? executer sera passer en argument du programme
- Les executables seront appel??s avec un chemin relatif ou absolut mais votre programme ne devra pas construire de chemin (en utilisant la variable d environment PATH par exemple)
- Votre programme doit implementer "|" et ";" comme dans bash
	- Nous n'essaierons jamais un "|" imm??diatement suivi ou pr??c??d?? par rien ou un autre "|" ou un ";"
- Votre programme doit implementer la commande "built-in" cd et seulement avec un chemin en argument (pas de '-' ou sans argument)
	- si cd n'a pas le bon nombre d'argument votre programme devra afficher dans STDERR "error: cd: bad arguments" suivi d'un '\n'
	- si cd a echou?? votre programme devra afficher dans STDERR "error: cd: cannot change directory to path_to_change" suivi d'un '\n' avec path_to_change remplacer par l'argument ?? cd
	- une commande cd ne sera jamais imm??diatement pr??c??d??e ou suivie par un "|"
- Votre programme n'a pas ?? gerer les "wildcards" (*, ~ etc...)
- Votre programme n'a pas ?? gerer les variables d'environment ($BLA ...)
- Si un appel systeme, sauf execve et chdir, retourne une erreur votre programme devra imm??diatement afficher dans STDERR "error: fatal" suivi d'un '\n' et sortir
- Si execve echoue votre programme doit afficher dans STDERR "error: cannot execute executable_that_failed" suivi d'un '\n' en ayant remplac?? executable_that_failed avec le chemin du programme qui n'a pu etre execut?? (ca devrait etre le premier argument de execve)
- Votre programme devrait pouvoir accepter des centaines de "|" meme si la limite du nombre de "fichier ouvert" est inferieur ?? 30.

Par exemple, la commande suivante doit marcher:
$>./microshell /bin/ls "|" /usr/bin/grep microshell ";" /bin/echo i love my microshell
microshell
i love my microshell
$>

Conseils:
N'oubliez pas de passer les variables d'environment ?? execve

Conseils:
Ne fuitez pas de file descriptor!
/bin/cat subject.fr.txt | /usr/bin/grep a | /usr/bin/grep w ; /bin/cat subject.fr.txt
Allowed functions: malloc, free, write, close, fork, waitpid, signal, kill, exit, chdir, execve, dup, dup2, pipe, strcmp, strncmp
- Votre programme n'a pas ?? gerer les "wildcards" (*, ~ etc...)
Assignment name  : microshell
Expected files   : *.c *.h
Allowed functions: malloc, free, write, close, fork, waitpid, signal, kill, exit, chdir, execve, dup, dup2, pipe, strcmp, strncmp
--------------------------------------------------------------------------------------

Ecrire un programme qui aura ressemblera ?? un executeur de commande shell
- La ligne de commande ?? executer sera passer en argument du programme
- Les executables seront appel??s avec un chemin relatif ou absolut mais votre programme ne devra pas construire de chemin (en utilisant la variable d environment PATH par exemple)
- Votre programme doit implementer "|" et ";" comme dans bash
	- Nous n'essaierons jamais un "|" imm??diatement suivi ou pr??c??d?? par rien ou un autre "|" ou un ";"
- Votre programme doit implementer la commande "built-in" cd et seulement avec un chemin en argument (pas de '-' ou sans argument)
	- si cd n'a pas le bon nombre d'argument votre programme devra afficher dans STDERR "error: cd: bad arguments" suivi d'un '\n'
	- si cd a echou?? votre programme devra afficher dans STDERR "error: cd: cannot change directory to path_to_change" suivi d'un '\n' avec path_to_change remplacer par l'argument ?? cd
	- une commande cd ne sera jamais imm??diatement pr??c??d??e ou suivie par un "|"
- Votre programme n'a pas ?? gerer les "wildcards" (*, ~ etc...)
- Votre programme n'a pas ?? gerer les variables d'environment ($BLA ...)
- Si un appel systeme, sauf execve et chdir, retourne une erreur votre programme devra imm??diatement afficher dans STDERR "error: fatal" suivi d'un '\n' et sortir
- Si execve echoue votre programme doit afficher dans STDERR "error: cannot execute executable_that_failed" suivi d'un '\n' en ayant remplac?? executable_that_failed avec le chemin du programme qui n'a pu etre execut?? (ca devrait etre le premier argument de execve)
- Votre programme devrait pouvoir accepter des centaines de "|" meme si la limite du nombre de "fichier ouvert" est inferieur ?? 30.

Par exemple, la commande suivante doit marcher:
$>./microshell /bin/ls "|" /usr/bin/grep microshell ";" /bin/echo i love my microshell
microshell
i love my microshell
$>

Conseils:
N'oubliez pas de passer les variables d'environment ?? execve

Conseils:
Ne fuitez pas de file descriptor!
/bin/cat subject.fr.txt ; /bin/cat subject.fr.txt | /usr/bin/grep a | /usr/bin/grep b | /usr/bin/grep z ; /bin/cat subject.fr.txt
Assignment name  : microshell
Expected files   : *.c *.h
Allowed functions: malloc, free, write, close, fork, waitpid, signal, kill, exit, chdir, execve, dup, dup2, pipe, strcmp, strncmp
--------------------------------------------------------------------------------------

Ecrire un programme qui aura ressemblera ?? un executeur de commande shell
- La ligne de commande ?? executer sera passer en argument du programme
- Les executables seront appel??s avec un chemin relatif ou absolut mais votre programme ne devra pas construire de chemin (en utilisant la variable d environment PATH par exemple)
- Votre programme doit implementer "|" et ";" comme dans bash
	- Nous n'essaierons jamais un "|" imm??diatement suivi ou pr??c??d?? par rien ou un autre "|" ou un ";"
- Votre programme doit implementer la commande "built-in" cd et seulement avec un chemin en argument (pas de '-' ou sans argument)
	- si cd n'a pas le bon nombre d'argument votre programme devra afficher dans STDERR "error: cd: bad arguments" suivi d'un '\n'
	- si cd a echou?? votre programme devra afficher dans STDERR "error: cd: cannot change directory to path_to_change" suivi d'un '\n' avec path_to_change remplacer par l'argument ?? cd
	- une commande cd ne sera jamais imm??diatement pr??c??d??e ou suivie par un "|"
- Votre programme n'a pas ?? gerer les "wildcards" (*, ~ etc...)
- Votre programme n'a pas ?? gerer les variables d'environment ($BLA ...)
- Si un appel systeme, sauf execve et chdir, retourne une erreur votre programme devra imm??diatement afficher dans STDERR "error: fatal" suivi d'un '\n' et sortir
- Si execve echoue votre programme doit afficher dans STDERR "error: cannot execute executable_that_failed" suivi d'un '\n' en ayant remplac?? executable_that_failed avec le chemin du programme qui n'a pu etre execut?? (ca devrait etre le premier argument de execve)
- Votre programme devrait pouvoir accepter des centaines de "|" meme si la limite du nombre de "fichier ouvert" est inferieur ?? 30.

Par exemple, la commande suivante doit marcher:
$>./microshell /bin/ls "|" /usr/bin/grep microshell ";" /bin/echo i love my microshell
microshell
i love my microshell
$>

Conseils:
N'oubliez pas de passer les variables d'environment ?? execve

Conseils:
Ne fuitez pas de file descriptor!N'oubliez pas de passer les variables d'environment ?? execve
Assignment name  : microshell
Expected files   : *.c *.h
Allowed functions: malloc, free, write, close, fork, waitpid, signal, kill, exit, chdir, execve, dup, dup2, pipe, strcmp, strncmp
--------------------------------------------------------------------------------------

Ecrire un programme qui aura ressemblera ?? un executeur de commande shell
- La ligne de commande ?? executer sera passer en argument du programme
- Les executables seront appel??s avec un chemin relatif ou absolut mais votre programme ne devra pas construire de chemin (en utilisant la variable d environment PATH par exemple)
- Votre programme doit implementer "|" et ";" comme dans bash
	- Nous n'essaierons jamais un "|" imm??diatement suivi ou pr??c??d?? par rien ou un autre "|" ou un ";"
- Votre programme doit implementer la commande "built-in" cd et seulement avec un chemin en argument (pas de '-' ou sans argument)
	- si cd n'a pas le bon nombre d'argument votre programme devra afficher dans STDERR "error: cd: bad arguments" suivi d'un '\n'
	- si cd a echou?? votre programme devra afficher dans STDERR "error: cd: cannot change directory to path_to_change" suivi d'un '\n' avec path_to_change remplacer par l'argument ?? cd
	- une commande cd ne sera jamais imm??diatement pr??c??d??e ou suivie par un "|"
- Votre programme n'a pas ?? gerer les "wildcards" (*, ~ etc...)
- Votre programme n'a pas ?? gerer les variables d'environment ($BLA ...)
- Si un appel systeme, sauf execve et chdir, retourne une erreur votre programme devra imm??diatement afficher dans STDERR "error: fatal" suivi d'un '\n' et sortir
- Si execve echoue votre programme doit afficher dans STDERR "error: cannot execute executable_that_failed" suivi d'un '\n' en ayant remplac?? executable_that_failed avec le chemin du programme qui n'a pu etre execut?? (ca devrait etre le premier argument de execve)
- Votre programme devrait pouvoir accepter des centaines de "|" meme si la limite du nombre de "fichier ouvert" est inferieur ?? 30.

Par exemple, la commande suivante doit marcher:
$>./microshell /bin/ls "|" /usr/bin/grep microshell ";" /bin/echo i love my microshell
microshell
i love my microshell
$>

Conseils:
N'oubliez pas de passer les variables d'environment ?? execve

Conseils:
Ne fuitez pas de file descriptor!
; /bin/cat subject.fr.txt ; /bin/cat subject.fr.txt | /usr/bin/grep a | /usr/bin/grep b | /usr/bin/grep z ; /bin/cat subject.fr.txt
Assignment name  : microshell
Expected files   : *.c *.h
Allowed functions: malloc, free, write, close, fork, waitpid, signal, kill, exit, chdir, execve, dup, dup2, pipe, strcmp, strncmp
--------------------------------------------------------------------------------------

Ecrire un programme qui aura ressemblera ?? un executeur de commande shell
- La ligne de commande ?? executer sera passer en argument du programme
- Les executables seront appel??s avec un chemin relatif ou absolut mais votre programme ne devra pas construire de chemin (en utilisant la variable d environment PATH par exemple)
- Votre programme doit implementer "|" et ";" comme dans bash
	- Nous n'essaierons jamais un "|" imm??diatement suivi ou pr??c??d?? par rien ou un autre "|" ou un ";"
- Votre programme doit implementer la commande "built-in" cd et seulement avec un chemin en argument (pas de '-' ou sans argument)
	- si cd n'a pas le bon nombre d'argument votre programme devra afficher dans STDERR "error: cd: bad arguments" suivi d'un '\n'
	- si cd a echou?? votre programme devra afficher dans STDERR "error: cd: cannot change directory to path_to_change" suivi d'un '\n' avec path_to_change remplacer par l'argument ?? cd
	- une commande cd ne sera jamais imm??diatement pr??c??d??e ou suivie par un "|"
- Votre programme n'a pas ?? gerer les "wildcards" (*, ~ etc...)
- Votre programme n'a pas ?? gerer les variables d'environment ($BLA ...)
- Si un appel systeme, sauf execve et chdir, retourne une erreur votre programme devra imm??diatement afficher dans STDERR "error: fatal" suivi d'un '\n' et sortir
- Si execve echoue votre programme doit afficher dans STDERR "error: cannot execute executable_that_failed" suivi d'un '\n' en ayant remplac?? executable_that_failed avec le chemin du programme qui n'a pu etre execut?? (ca devrait etre le premier argument de execve)
- Votre programme devrait pouvoir accepter des centaines de "|" meme si la limite du nombre de "fichier ouvert" est inferieur ?? 30.

Par exemple, la commande suivante doit marcher:
$>./microshell /bin/ls "|" /usr/bin/grep microshell ";" /bin/echo i love my microshell
microshell
i love my microshell
$>

Conseils:
N'oubliez pas de passer les variables d'environment ?? execve

Conseils:
Ne fuitez pas de file descriptor!Assignment name  : microshell
Expected files   : *.c *.h
Allowed functions: malloc, free, write, close, fork, waitpid, signal, kill, exit, chdir, execve, dup, dup2, pipe, strcmp, strncmp
--------------------------------------------------------------------------------------

Ecrire un programme qui aura ressemblera ?? un executeur de commande shell
- La ligne de commande ?? executer sera passer en argument du programme
- Les executables seront appel??s avec un chemin relatif ou absolut mais votre programme ne devra pas construire de chemin (en utilisant la variable d environment PATH par exemple)
- Votre programme doit implementer "|" et ";" comme dans bash
	- Nous n'essaierons jamais un "|" imm??diatement suivi ou pr??c??d?? par rien ou un autre "|" ou un ";"
- Votre programme doit implementer la commande "built-in" cd et seulement avec un chemin en argument (pas de '-' ou sans argument)
	- si cd n'a pas le bon nombre d'argument votre programme devra afficher dans STDERR "error: cd: bad arguments" suivi d'un '\n'
	- si cd a echou?? votre programme devra afficher dans STDERR "error: cd: cannot change directory to path_to_change" suivi d'un '\n' avec path_to_change remplacer par l'argument ?? cd
	- une commande cd ne sera jamais imm??diatement pr??c??d??e ou suivie par un "|"
- Votre programme n'a pas ?? gerer les "wildcards" (*, ~ etc...)
- Votre programme n'a pas ?? gerer les variables d'environment ($BLA ...)
- Si un appel systeme, sauf execve et chdir, retourne une erreur votre programme devra imm??diatement afficher dans STDERR "error: fatal" suivi d'un '\n' et sortir
- Si execve echoue votre programme doit afficher dans STDERR "error: cannot execute executable_that_failed" suivi d'un '\n' en ayant remplac?? executable_that_failed avec le chemin du programme qui n'a pu etre execut?? (ca devrait etre le premier argument de execve)
- Votre programme devrait pouvoir accepter des centaines de "|" meme si la limite du nombre de "fichier ouvert" est inferieur ?? 30.

Par exemple, la commande suivante doit marcher:
$>./microshell /bin/ls "|" /usr/bin/grep microshell ";" /bin/echo i love my microshell
microshell
i love my microshell
$>

Conseils:
N'oubliez pas de passer les variables d'environment ?? execve

Conseils:
Ne fuitez pas de file descriptor!Assignment name  : microshell
Expected files   : *.c *.h
Allowed functions: malloc, free, write, close, fork, waitpid, signal, kill, exit, chdir, execve, dup, dup2, pipe, strcmp, strncmp
--------------------------------------------------------------------------------------

Ecrire un programme qui aura ressemblera ?? un executeur de commande shell
- La ligne de commande ?? executer sera passer en argument du programme
- Les executables seront appel??s avec un chemin relatif ou absolut mais votre programme ne devra pas construire de chemin (en utilisant la variable d environment PATH par exemple)
- Votre programme doit implementer "|" et ";" comme dans bash
	- Nous n'essaierons jamais un "|" imm??diatement suivi ou pr??c??d?? par rien ou un autre "|" ou un ";"
- Votre programme doit implementer la commande "built-in" cd et seulement avec un chemin en argument (pas de '-' ou sans argument)
	- si cd n'a pas le bon nombre d'argument votre programme devra afficher dans STDERR "error: cd: bad arguments" suivi d'un '\n'
	- si cd a echou?? votre programme devra afficher dans STDERR "error: cd: cannot change directory to path_to_change" suivi d'un '\n' avec path_to_change remplacer par l'argument ?? cd
	- une commande cd ne sera jamais imm??diatement pr??c??d??e ou suivie par un "|"
- Votre programme n'a pas ?? gerer les "wildcards" (*, ~ etc...)
- Votre programme n'a pas ?? gerer les variables d'environment ($BLA ...)
- Si un appel systeme, sauf execve et chdir, retourne une erreur votre programme devra imm??diatement afficher dans STDERR "error: fatal" suivi d'un '\n' et sortir
- Si execve echoue votre programme doit afficher dans STDERR "error: cannot execute executable_that_failed" suivi d'un '\n' en ayant remplac?? executable_that_failed avec le chemin du programme qui n'a pu etre execut?? (ca devrait etre le premier argument de execve)
- Votre programme devrait pouvoir accepter des centaines de "|" meme si la limite du nombre de "fichier ouvert" est inferieur ?? 30.

Par exemple, la commande suivante doit marcher:
$>./microshell /bin/ls "|" /usr/bin/grep microshell ";" /bin/echo i love my microshell
microshell
i love my microshell
$>

Conseils:
N'oubliez pas de passer les variables d'environment ?? execve

Conseils:
Ne fuitez pas de file descriptor!
blah | /bin/echo OK
OK

blah | /bin/echo OK ;
OK

