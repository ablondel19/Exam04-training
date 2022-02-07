/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   test.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: ablondel <ablondel@student.s19.be>         +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2022/02/07 14:09:07 by ablondel          #+#    #+#             */
/*   Updated: 2022/02/07 16:56:15 by ablondel         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#define PIPE 1
#define BREAK 2
#define ARG 3

void	print(char *args[1000], int argtype[1000], size_t j)
{
	for (size_t i = 0; i < j; i++)
	{
		if (argtype[i] == PIPE)
		{
			printf("{/// PIPE ///}\n");
			i++;
		}
		else if (argtype[i] == BREAK)
		{
			printf("{/// BREAK ///}\n");
			i++;
		}
		printf("{ %s | %d } \n", args[i], argtype[i]);
	}
	printf("{///// END /////}\n");
}

int		is_piped(char *args[1000], int *index, size_t j)
{
	for (size_t i = *index; i < j; i++)
	{
		if (args[i][0] == '|')
		{
			args[i][0] = '\0';
			*index = i + 1;
			return (i);
		}
		if (args[i][0] == ';')
		{
			args[i][0] = '\0';
			*index = i + 1;
			return (0);
		}
	}
	return (-1);
}

void	pipeline(char *args[1000], int argtype[1000], int j)
{
	(void)argtype;
	//int pfd[2];
	//pid_t pid;
	int index = 0;
	//int i = 0;

	is_piped(args, &index, j);
	printf("%s\n", args[index]);
	//while (is_piped(args, &index, j) != -1)
	//{
	//	if (pipe(pfd) == -1)
	//		exit(1);
	//	pid = fork();
	//	if (pid == -1)
	//		exit(1);
	//	else if (pid == 0)
	//	{
	//		if (argtype[index - 1] == PIPE)
	//			dup2(pfd[1], 1);
	//		close(pfd[0]);
	//		close(pfd[1]);
	//		execve(args[index], &args[index], NULL);
	//		exit(1);
	//	}
	//	else
	//	{
	//		if (argtype[index - 1] == PIPE)
	//			dup2(pfd[0], 0);
	//		waitpid(pid, NULL, 0);
	//		close(pfd[0]);
	//		close(pfd[1]);
	//	}
	//	i++;
	//}
}

int		main(int ac, char **av)
{
	(void)ac;
	size_t i = 1;
	size_t j = 0;
	char	*args[1000] = {[0 ... 999] = 0};
	int		argtype[1000] = {[0 ... 999] = 0};

	while (av[i])
	{
		args[j] = av[i];
		if (av[i][0] == '|')
			argtype[j] = PIPE;
		else if (av[i][0] == ';')
			argtype[j] = BREAK;
		else
			argtype[j] = ARG;
		j++;
		i++;
	}
	pipeline(args, argtype, j);
}