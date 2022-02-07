/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   test.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: ablondel <ablondel@student.s19.be>         +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2022/02/07 14:09:07 by ablondel          #+#    #+#             */
/*   Updated: 2022/02/07 15:43:38 by ablondel         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#define PIPE 1

void	pipeline(char **cmd, int type)
{
	(void)cmd;
	int pfd[2];
	pid_t pid;

	if (pipe(pfd) == -1)
		exit(1);
	pid = fork();
	if (pid == -1)
		exit(1);
	else if (pid == 0)
	{
		if (type == PIPE)
			dup2(pfd[1], 1);
		close(pfd[0]);
		close(pfd[1]);
		execve(cmd[0], &cmd[0], NULL);
		exit(1);
	}
	else
	{
		if (type == PIPE)
			dup2(pfd[0], 0);
		waitpid(pid, NULL, 0);
		close(pfd[0]);
		close(pfd[1]);
	}
}

int		main(int ac, char **av)
{
	(void)ac;
	int i = 1;
	char **cmd = NULL;
	int cmdi = 0;

	while (av[i])
	{
		cmd[cmdi] = av[i];
		cmdi++;
		i++;
	}
	//pipeline(cmd, 0);
}