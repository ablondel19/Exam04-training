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
					execve((*cmd)[0], &(*cmd)[0], env);
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
	exit(0);
}

int		main(int ac, char **av, char **env)
{
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
