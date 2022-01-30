/* parent creates all needed pipes at the start *//////////////////////////////////////
//
//
//
//			for( i = 0; i < num-pipes; i++ ){
//			
//			    if( pipe(pipefds + i*2) < 0 ){
//			        perror and exit
//			    }
//			}
//			
//			commandc = 0
//			while( command ){
//			    pid = fork()
//			    if( pid == 0 ){
//			        /* child gets input from the previous command,
//			            if it's not the first command */
//			        if( not first command ){
//			            if( dup2(pipefds[(commandc-1)*2], 0) < ){
//			                perror and exit
//			            }
//			        }
//			        /* child outputs to next command, if it's not
//			            the last command */
//			        if( not last command ){
//			            if( dup2(pipefds[commandc*2+1], 1) < 0 ){
//			                perror and exit
//			            }
//			        }
//			        close all pipe-fds
//			        execvp
//			        perror and exit
//			    } else if( pid < 0 ){
//			        perror and exit
//			    }
//			    cmd = cmd->next
//			    commandc++
//			}
//			
//			/* parent closes all of its copies at the end */
//			for( i = 0; i < 2 * num-pipes; i++ ){
//			    close( pipefds[i] );
//			}
//
#include <stdlib.h>
#include <stdio.h>

typedef struct	s_list
{
	char		**args;
	void		*next;
}				t_list;


void exec(t_list* cmd, char *userInput)
{
    int npipes = countPipes(userInput);
    pid_t pid;
    int pfd[2 * npipes];
    for (int i = 0; i < npipes; i++)
	{
        if (pipe(pfd + i * 2) < 0) 
		{
            exit(EXIT_FAILURE);
        }
    }
    int j = 0;
    while (cmd) 
	{
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
            if (execvp(*cmd->args, cmd->args) < 0)
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
        wait(NULL);
	}
}
