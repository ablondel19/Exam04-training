#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <unistd.h>
#define PIPE 1
#define BREAK 2
#define ARG 3

typedef struct		s_list
{
	char			**args;
	int				is_piped;
	void			*next;
}					t_list;

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
	if (strcmp(av, "|") == 0)
		return PIPE;
	else if (strcmp(av, ";") == 0)
		return BREAK;
	return ARG;
}

void exec(t_list *cmd, char **env)
{
	(void)env;
    pid_t pid;
    int j = 0;
	int npipes = 0;
    int *pfd;
    while (cmd) 
	{
		pfd = malloc(2*npipes*sizeof(int));
    	for (int i = 0; i < npipes; i++)
		{
    	    if (pipe(pfd + i * 2) < 0) 
			{
    	        exit(EXIT_FAILURE);
    	    }
    	}
        pid = fork();
        if (pid == 0)
		{
            //if not last cmd
            if (cmd->next)
			{
          		if (dup2(pfd[j + 1], 1) < 0)
				{
                    exit(EXIT_FAILURE);
                }
				npipes--;
            }
            //if not first cmd&& j != 2 * npipes
            if (j != 0 && j != 2 * npipes)
			{
                if (dup2(pfd[j - 2], 0) < 0)
				{
                    exit(EXIT_FAILURE);
                }
            }
            for(int i = 0; i < 2 * npipes; i++)
			{
                close(pfd[i]);
            }
            if (execve(*cmd->args, cmd->args, env) < 0)
			{
                exit(EXIT_FAILURE);
            }
        }
		else if (pid < 0)
		{
            exit(EXIT_FAILURE);
        }
		cmd = cmd->next;
        j += 2;
    }
    //Parent closes the pipes and wait for children
    for(int i = 0; i < 2 * npipes; i++)
	{
        close(pfd[i]);
    }
    for(int i = 0; i < npipes + 1; i++)
	{
        waitpid(pid, NULL, 0);
	}
}

void	print(t_list *lst)
{
	int i = 0;
	while (lst)
	{
		printf("<<<[%d] PIPED\n", lst->is_piped);
		while (lst->args[i])
		{
			printf("{%s}\n", lst->args[i++]);
		}
		printf("===NEXT>>>\n\n");
		lst = lst->next;
		i = 0;
	}
}

t_list *newnode(char **data, int start, int end)
{
	int i = 0;
	t_list *node = NULL;
	node = malloc(sizeof(t_list));
	node->args = malloc(sizeof(char*) * (end + 1));
	while (start < end && ft_type(data[start]) != BREAK && ft_type(data[start]) != PIPE)
	{
		node->args[i] = ft_strdup(data[start]);
		start += 1;
		i++;
	}
	node->args[i] = 0;
	node->next = NULL;
	return node;
}

void	push(t_list **lst, t_list *node)
{
	t_list *tmp = *lst;
	if (!(*lst))
	{
		node->next =  (*lst);
		(*lst) = node;
		return ;
	}
	while ((*lst)->next)
	{
		(*lst) = (*lst)->next;
	}
	(*lst)->next = node;
	(*lst) = tmp;
}

int		tabsize(char **tab)
{
	int i = 0;
	while (tab[i])
		i++;
	return i;
}

int		main(int ac, char **av, char **env)
{
	(void)ac;
	(void)env;
	int i = 1;
	t_list *lst = NULL;
	t_list *new = NULL;

	if (ac >= 2)
	{
		while (av[i] && i < ac)
		{
			if (ft_type(av[i - 1]) == PIPE)
				new->is_piped = 1;
			if (ft_type(av[i]) == ARG)
			{
				new = newnode(av, i, ac);
				i += tabsize(new->args);
				push(&lst, new);
			}
			i++;
		}
		print(lst);
	}
	return 0;
}
