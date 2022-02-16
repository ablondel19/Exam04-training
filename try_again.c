#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <string.h>
#include <stdio.h>
#define BREAK 1

void	ft_free(char **cmd)
{
	int i = 0;
	while (cmd[i])
	{
		free(cmd[i]);
		i++;
	}
	free(cmd);
}

void	ft_putstr(char *s)
{
	while (*s)
		write(2, s++, 1);
}

void		error_fatal(void)
{
	ft_putstr("error fatal\n");
	exit(1);
}

int		ft_strlen(char *s)
{
	int i = 0;
	while (s[i])
		i++;
	return i;
}

char	*ft_strdup(char *src)
{
	int i = -1;
	char *dst = NULL;
	dst = malloc(sizeof(char) * (ft_strlen(src) + 1));
	if (!dst)
		error_fatal();
	while (src[++i])
		dst[i] = src[i];
	dst[i] = '\0';
	return dst;
}

void		ft_chdir(char **cmd)
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
	return ;
}

char		**next_pipe(int ac, char **av, int *index, int *type)
{
	int 	i = *index;
	int		j = 0;
	char	**cmd = NULL;
	if (*index > ac)
		return NULL;
	cmd = (char**)malloc(sizeof(char*) * (ac + 1));
	if (!cmd)
		error_fatal();
	while (av[i] && av[i][0] != '|' && av[i][0] != ';')
	{
		cmd[j] = ft_strdup(av[i]);
		i++;
		j++;
	}
	*type = 0;
	if (i < ac && av[i][0] == ';')
		*type = BREAK;
	cmd[j] = 0;
	*index = i + 1;
	return cmd;
}

void	pipeline(int ac, char **av, char **env)
{
	char **cmd = NULL;
	int i = 1;
	int type = 0;
	int pid = 0;
	int pfd[2];
	int piped = 0;

	while (((cmd = next_pipe(ac, av, &i, &type)) != NULL))
	{
		piped = 0;
		if (cmd[0])
		{
			if (strcmp(cmd[0], "cd") == 0)
			{
				ft_chdir(cmd);
			}
			else
			{
				if (pipe(pfd) == -1)
					error_fatal();
				else
					piped = 1;
				pid = fork();
				if (pid == -1)
					error_fatal();
				else if (pid == 0)
				{
					if (type != BREAK && i < ac)
					{
						if (dup2(pfd[1], 1) == -1)
							error_fatal();
						if (close(pfd[0]) == -1 || close(pfd[1]) == -1)
							error_fatal();
						piped = 0;
					}
					execve(cmd[0], &cmd[0], env);
					ft_putstr("error: cannot execute ");
					ft_putstr(cmd[0]);
					ft_putstr("\n");
				}
				else
				{
					if (type != BREAK)
					{
						if (dup2(pfd[0], 0) == -1)
							error_fatal();
						if (close(pfd[0]) == -1 || close(pfd[1]) == -1)
							error_fatal();
						piped = 0;
					}
					waitpid(0, 0, 0);
					if (piped)	
						if (close(pfd[0]) == -1 || close(pfd[1]) == -1)
							error_fatal();
				}
			}
			if (i >= ac)
				return ;
		}
		if (cmd)
			ft_free(cmd);
	}
}

int		main(int ac, char **av, char **env)
{
	if (ac >= 2)
		pipeline(ac, av, env);
	return 0;
}

