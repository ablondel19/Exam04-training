#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#define ARG 1
#define PIPE 2
#define BREAK 3

void	ft_putstr(char *s)
{
	while (*s)
		write(2, s++, 1);
}

void	ft_free(char **res)
{
	int i = 0;
	while (res[i])
		free(res[i++]);
	free(res);
}

int		ft_strlen(char *s)
{
	int i = 0;
	while (s[i])
		i++;
	return i;
}

void	error_fatal()
{
	ft_putstr("error fatal\n");
	exit(1);
}

char	*ft_strdup(char *src)
{
	int 	i = -1;
	char	*dst = NULL;
	dst = malloc(sizeof(char) * (ft_strlen(src + 1)));
	if (!dst)
		error_fatal();
	while (src[++i])
		dst[i] = src[i];
	dst[i] = '\0';
	return dst;
}

char	**next_pipe(int ac, char **av, int *index, int *type)
{
	int 	i = *index;
	int		j = 0;
	char	**res = NULL;
	int		size = 0;
	if (*index > ac)
		return NULL;
	while (av[i] && av[i][0] != '|')
	{
		size++;
		i++;
	}
	i = *index;
	res = (char**)malloc(sizeof(char*) * (size + 1));
	if (!res)
		error_fatal();
	if (i < ac && av[i][0] == ';')
	{
		while (i < ac && av[i][0] == ';')
			i++;
	}	
	while (av[i] && av[i][0] != '|' && i && av[i][0] != ';' && i < ac)
	{
		res[j] = ft_strdup(av[i]);
		i++;
		j++;
	}
	*type = 0;
	if (i < ac && av[i][0] == ';')
		*type = BREAK;
	*index = i + 1;
	res[j] = NULL;
	return res;
}

void	ft_chdir(char **res)
{
	if (!res[1] || res[2])
	{
		ft_putstr("error: cd: bad arguments\n");
		return ;
	}
	if (chdir(res[1]) == -1)
	{
		ft_putstr("error: cd: cannot change directory to ");
		ft_putstr(res[1]);
		ft_putstr("\n");
		return ;
	}
}

void	pipeline(int ac, char **av, char **env)
{
	(void)env;
	int		index = 1;
	char	**res = NULL;
	int		pfd[2];
	int		pid = 0;
	int		type = 0;
	while (((res = next_pipe(ac, av, &index, &type)) != NULL) && index <= ac + 1)
	{
		if (index > ac && type == 0)
			return ;
		if (strcmp(res[0], "cd") == 0)
			ft_chdir(res);
		else
		{
			if (pipe(pfd) == -1)
				error_fatal();
			pid = fork();
			if (pid == -1)
				error_fatal();
			else if (pid == 0)
			{
				if (index < ac && type != BREAK)
				{
					if (dup2(pfd[1], 1) == -1)
						error_fatal();
					if (close(pfd[0]) == -1 || close(pfd[1]) == -1)
						error_fatal();
				}
				execve(res[0], &res[0], env);
				ft_putstr("error: cannot execute ");
				ft_putstr(res[0]);
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
				}
				waitpid(0, 0, 0);
			}
		}
		if (res)
			ft_free(res);
		res = NULL;
	}
	if (res)
		ft_free(res);
}

int		main(int ac, char **av, char **env)
{
	if (ac >= 2)
	{
		pipeline(ac, av, env);
		//system("leaks a.out");
		return 0;
	}
}
