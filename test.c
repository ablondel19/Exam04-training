/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   test.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: ablondel <ablondel@student.s19.be>         +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2022/02/07 14:09:07 by ablondel          #+#    #+#             */
/*   Updated: 2022/02/08 17:21:32 by ablondel         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <signal.h>
#define PIPE 1
#define BREAK 2
#define ARG 3

void	ft_putstr(char *s)
{
	while (*s)
		write(2, s++, 1);
}

void	error_fatal()
{
	ft_putstr("error fatal\n");
	exit(1);
}

void	ft_chdir(char **cmd)
{
	if (!*(cmd + 1) || *(cmd + 2))
	{
		ft_putstr("error: cd: bad arguments\n");
		return ;
	}
	if (chdir(*(cmd + 1)) == -1)
	{
		ft_putstr("error: cd: cannot change directory to ");
		ft_putstr(*(cmd + 1));
		ft_putstr("\n");
		return ;
	}
}

void	pipeline(char ***cmd, int *type, char **env)
{
	int index = 0;
	int pfd[2];
	int pid = 0;

	while (*cmd)
	{
		if (strcmp((*cmd)[0], "cd") == 0)
			ft_chdir(*cmd);
		else if ((*cmd)[0] != NULL)
		{
			if (pipe(pfd) == -1)
				error_fatal();
			if ((pid = fork()) == -1)
				error_fatal();
			else if (pid == 0)
			{
				if (type[index] == PIPE && *(cmd + 1))
				{
					if (dup2(pfd[1], 1) == -1)
						error_fatal();
					close(pfd[0]);
					close(pfd[1]);
				}
				execve((*cmd)[0], &(*cmd)[0], env);
				ft_putstr("error: cannot execute ");
				ft_putstr((*cmd)[0]);
				ft_putstr("\n");
				exit(1);
			}
			else
			{
				if (type[index] == PIPE)
				{
					if (dup2(pfd[0], 0) == -1)
						error_fatal();
					close(pfd[0]);
					close(pfd[1]);
				}
				waitpid(0, 0, 0);
			}
			close(pfd[0]);
			close(pfd[1]);
		}
		index++;
		cmd++;
	}
}

int		main(int ac, char **av, char **env)
{
	size_t 	i = 1;
	int 	cmdi = 0;
	int 	cmdj = 0;
	char	***args = NULL;
	int		*type = NULL;

	if (ac >= 2)
	{
		args = malloc(sizeof(char**) * ac);
		type = malloc(sizeof(int) * ac);
		if (!args || !type)
			error_fatal();
		for (size_t i = 0; i < ac; i++)
		{
			type[i] = 0;
			args[i] = malloc(sizeof(char*) * ac);
			if (!args[i])
				error_fatal();
		}
		while (av[i])
		{
			if (av[i][0] == '|')
			{
				type[cmdi] = PIPE;
				args[cmdi][cmdj] = 0;
				cmdj = 0;
				cmdi++;
				i++;
			}
			else if (av[i][0] == ';')
			{
				type[cmdi] = BREAK;
				args[cmdi][cmdj] = 0;
				cmdj = 0;
				cmdi++;
				while (av[i][0] == ';')
					i++;
			}
			type[cmdi] = ARG;
			args[cmdi][cmdj] = av[i];
			cmdj++;
			i++;
		}
		args[cmdi][cmdj] = 0;
		args[cmdi + 1] = 0;
		pipeline(args, type, env);
		for (size_t i = 0; i < ac; i++)
		{
			if (args[i])
				free(args[i]);
		}
		free(args);
		free(type);
	}
	exit(0);
}
