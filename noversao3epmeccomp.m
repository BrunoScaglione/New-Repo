
%%%%%%%%%%%%%%%%%%%%%%%%%%%% CONSTANTES %%%%%%%%%%%%%%%%%%%%%%%%%%


%%%% valores
V = 100/3.6; % velocidade 
Tdentro = 40; % T dentro
Tfora = 20; % Tfora

%%%%dimensoes
d = 15;
h = 3;
r = 3;
L = 6;
H = 24;
l = 60;

%coordenadas do centro do semicirculo (telhado)
centro_cir_x = d + r;
centro_cir_y = h;

% largura total
width = 2*d + L;

%%%% area do telhado projetada no plano xz
area_telhado_projecaoxz = l*L;

%%%%propriedades
ro = 1.25;
yar = 1.4;
kar = 0.026;
cp = 1002;


%%%%discretizacao
dx = h/8;
dy = dx;

%%%% constantes utilizadas nas equa��es da EDP de Temperatura
C1 = (ro*cp)/dx;
C2 = kar/(dx^2);

%%%% numero de pontos de discretizacao no telhado no eixo x 
num_points = (L/dx) + 1;


%%%%%%%%%%%%%%%%%%%%%%% GRID %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%grid
xrange = 0:dx:width; % + 1 eh pra quando plotar aparecer o quadradinho do ultimo
yrange = 0:dy:H;
[x,y] = meshgrid(xrange,yrange);
leny = length(yrange);
lenx = length(xrange);

% apenas para fazer contas matriciais 
Lmatrix = zeros(leny,lenx)+ L;
dmatrix = zeros(leny,lenx)+ d;
hmatrix = zeros(leny,lenx)+ h;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% IN�CIO DO PROGRAMA %%%%%%%%%%%%%%%%%%%%%%%

% Tanto para a EDP de psi quanto para a EDP da Temperatura foram feitas
% tr�s matrizes, al�m das pedidas.
 
% Matriz dos n�s no grid, que mostra os
% diferentes tipos de n�s;

% Matriz de condi��es de contorno, na qual, se 
% for uma borda, ter� o valor da condi��o de contorno desse ponto, seja de
% dichelet ou Newmann.

% Matriz com os valores inciais.� a matriz com os valores inciais que vai
% iterada no algoritmo de Liebamm. Nos pontos onde tem condi��o de
% dirichelet, ela assume o valor da condi��o de contorno, nos outros assume
% um valor inicial. No caso do psi, foi iniciada com zeros, no caso da
% temperatura foi iniciada � 20 graus Celsius para acelerar a converg�ncia.

% 1. Matriz dos n�s
    % Aqui foi atribu�do n�meros diferentes para cada tipo de n�:
    % pontos internos -> 1
        % n�s internos da malha, onde ser� poss�vel aplicar apenas
        % diferen�as centrais.
    % predio (galp�o) -> 0
        % n�s dentro do pr�dio ou galp�o, que estar�o dentro da condi��o
        % de contorno de dirichelet, com valor fixo
    % borda de dirichelet -> 0
        % n�s das bordas do grid que estar�o dentro da condi��o de
        % dirichelet tamb�m.
    % borda de dirichelet em cheio -> 0.5  
        % quando o ponto coincide
        % exatamente com a curva do semic�rculo, e portanto t� na borda de
        % dirichelet, por�m o ponto acima dele n�o vai ser pr�
        % irregularidade.
    % borda de newmann -> 3
        % n�s que est�o sobre uma borda com condi��o de contorno de
        % Newmann. Ou seja a derivada � conhecida 
    % pontos pr� irregularidade -> 4
        % n�s que est�o ao lado de uma irregularidade no grid, ou seja est�
        % � uma dist�ncia menor que dx da borda em algum eixo ou nos dois
        % eixos
        
        
% 2. Matriz das condi��es de contorno
    % Cada n� vai receber o vaor da condi��o de controno dele, seja de
    % dirichelet ou Newmann. Se for um n� interno, � simplismente
    % atribbu�do -1, indicando que n�o faz sentido nesse caso
    
% 3. Matriz com os valores inicias
    % uma matriz com os valorees inicias que receber� os valores d
    % condi��o de dichelet.
    
    
    
 % OBSERVA��ES IMPORTANTES: 
    % 1.
        % A fun��o Condi��es vai identificar os tipos de n�s na malha, e
        % atribuir os valores � esse n�s numa matriz que foi fornecida para
        % ela. Ent�o ela � usada na cria��o dessas tr�s mmatrizes acima.
        
    % 2. 
        % A fun��o relaxa vai aplicar a sobrerelaxa��o com o lambda
        % fornecido para ela, ser� usada muito no algoritmo de Liebmann
        
    % 3.
        % Foi adotada uma conven��o de dire��o para a utiliza��o da fun��o
        % que calcula o valor no ponto de uma parede de Newmann, ou seja,
        % que faz taylor em uma eixo e diferenca central no outro. A
        % direcao = 1 � quando o taylor vais er feito para ponto psterior,
        % e 0 quando � pra ponto interior. 
        
        %A nota��o  de direcao  tamb�m foi utulizada na fun��o que calcula
        %derivada num ponto pr� irregularidade, e nesse caso dire��o == 1
        %sigifica qe o taylor que se faz para chegar na condi��o de
        %contorno da borda � para ponto posterior (� esquerda do galp�o), enquanto para direcao ==
        %0 � para ponto anterior (� direita do galp�o).
        
    % 4.
        % A nota��o utilizada, foi que o i indica as linhas e o j indica as
        % colunas, a nota��o matricial, par afacilitar a manipula��o das
        % matrizes. � diferente da nota��o utlizada nas contas e nos
        % equacionamentos no papel das equa��es. Na matrizes de coordenadas do grid, x cresce
        % para direita e y cresce para baixo, ou seja ela est� espelhada em
        % rela��o ao que se v� nas figuras.
    % 5. 
        % Ao que se � nas figuras, o algritmo vai percorrendo linha por
        % linha, da esquerda para direita, come�ando no ponto(0,0), tomando a
        % origrm como o ponto mais � esquerda e mais para baixo.
     
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SETUP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%% N�S PSI (PARTE 1)

nos_psi = ones(leny, lenx);
% ... dmatrix, valor_preirregular, valor_predio, valor_bordadichelet, valor_bordadichelet_emcheio, valor_bordanewmann_x, valor_bordanewmann_y);
nos_psi = Condicoes_psi(nos_psi, x, y, d, L, H, width, dx, Lmatrix, dmatrix, h, 4, 0, 0, 0.5, 3, 3);

% nessa figura � poss�vel ver os npos da malha. 
% por�m n�o pe possivel ver os n�s da �ltima linha e da �ltima coluna, pois
% no gr�fico eles n�o ficam pintados na vista de 90 graus

figure(1)
surf(x, y, nos_psi)
view(0,90)

%%%%%%%% N�S TEMPERATURA (PARTE 2)

nos_T = ones(leny, lenx);
%...dmatrix, valor_preirregular, valor_predio, valor_bordadichelet, valor_bordadichelet_emcheio, valor_bordanewmann);
nos_T = Condicoes_T(nos_T, x, y, d, L, H, width, dx, Lmatrix, dmatrix, h, 4, 0, 0, 0.5, 3);


% nessa figura � poss�vel ver os nos da malha. 
% por�m n�o pe possivel ver os n�s da �ltima linha e da �ltima coluna, pois
% no gr�fico eles n�o ficam pintados na vista de 90 graus

figure(2)
surf(x, y, nos_T)
view(0,90)

%%%%%%%%%%%% Valores das condicoes de contorno de PSI

% pontos que sao de borda -> valor da cc
% outros pontos -> -1 s� pra indicar
cc_T = zeros(leny, lenx) -1;
%...dmatrix, valor_preirregular, valor_predio, valor_bordadichelet, valor_bordadichelet_emcheio, valor_bordanewmann);
cc_T = Condicoes_T(cc_T, x, y, d, L, H, width, dx, Lmatrix, dmatrix, h, -1, Tdentro, Tfora, Tdentro, 0);


%%%%%%%%%%%% Valores das condicoes de contorno de TEMPERATURA

% pontos que sao de borda -> valor da cc
% outros pontos -> -1 s� pra indicar
cc_psi = zeros(leny, lenx) -1;
%...dmatrix, valor_preirregular, valor_predio, valor_bordadichelet, valor_bordadichelet_emcheio, valor_bordanewmann_x, valor_bordanewmann_y);
cc_psi = Condicoes_psi(cc_psi, x, y, d, L, H, width, dx, Lmatrix, dmatrix, h, -1, 0, 0, 0, 0, V);


%%%%%%%%%%%% MATRIZ PSI INICIAL

psi_matrix = zeros(leny, lenx);
% ... dmatrix, valor_preirregular, valor_predio, valor_bordadichelet, valor_bordadichelet_emcheio, valor_bordanewmann_x, valor_bordanewmann_y);
psi_matrix = Condicoes_psi(psi_matrix, x, y, d, L, H, width, dx, Lmatrix, dmatrix, h, 0, 0, 0, 0, 0, 0);

%%%%%%% MATRIZ TEMPERATURA INICIAL

T_matrix = zeros(leny, lenx) + 20;
%...dmatrix, valor_preirregular, valor_predio, valor_bordadichelet, valor_bordadichelet_emcheio, valor_bordanewmann);
T_matrix = Condicoes_T(T_matrix, x, y, d, L, H, width, dx, Lmatrix, dmatrix, h, 20, Tdentro, Tfora, Tdentro, 20);

%%%%%%%% matrizes do campo de velocidades
v_matrix  = zeros(leny, lenx);
u_matrix  = zeros(leny, lenx);
U_matrix = zeros(leny, lenx);

%%%%%%% matriz de vaira��o de press�o e pressao no telhado %%%%
pvar_matrix = zeros(leny, lenx);
%obs: nessa matriz, futuramente s� ser�o preenchidos os valores
% correspondentes � pontos sobre o telhado
ptelhado_matrix = zeros(leny, lenx);


%%%%%%%% CONCATENA��O DAS MATRIZES %%%%%%%%


% Para ficilitar o trabalho com todas as matrizes que correpondem � malha.
% Foi colocado tudo em diferentes camadas de uma matriz malha com dimens�o
% 12, e ela ser� referida no programa inteiro.

% ind�ces:
% 1 - coordenada x
% 2 - coordenada y
% 3 - tipo de n� no grid, do PSI
% 4 - condi��o de contorno de n� se tiver, do PSI
% 5 - matriz inicial de PSI
% 6 - componente vertical da velocidade no n�
% 7 - componente horizontal da velocidade no n� 
% 8 - velocidade absoluta no n�
% 9 - varia��o de press�o do n�
% 10 - tipo de n� no grid, da TEMPERATURA
% 11 - condi��o de contorno de n� se tiver, da TEMPERATURA
% 12 - matriz inicial de TEMPERATURA
   
malha = cat(3,x, y, nos_psi,cc_psi, psi_matrix, v_matrix, u_matrix, U_matrix, pvar_matrix, nos_T, cc_T, T_matrix);

%%%%%%%%%%%%%% ALGORITMO DE LIEBMANN PARA PARTE 1

len_lines = leny;
len_rows = lenx;

lambda_psi = 1.85;
% maximo erro
max_e_psi = 1;
it = 1;

disp("Iniciando Liebmann para o PSI")
while max_e_psi > 0.0001
    %  copia da matriz atual, par usar no calculo do erro
    current_matrix_psi = malha(:,:,5);
    for i = 1:len_lines
        for j = 1:len_rows
            % valor atual 
            velho = malha(i, j, 5);
            x_ponto = malha(i,j,1);
            y_ponto = malha(i,j,2);
            switch malha(i, j, 3)
                case 1
                    % ponto interno
                    psi_pontoantes_x = malha(i, j-1, 5);
                    psi_pontodepois_x = malha(i, j+1, 5);
                    psi_pontoantes_y = malha(i-1, j, 5);
                    psi_pontodepois_y = malha(i+1, j, 5);
                    % 2a dif central
                    novo = (...
                        psi_pontodepois_x + psi_pontoantes_x ...
                        + psi_pontodepois_y + psi_pontoantes_y...
                    )/4;
                    % sobrerelaxa��o
                    malha(i, j, 5) = relaxa(novo, velho, lambda_psi);
                case 0
                case 0.5
                case 3
                    % Newmann -> Taylor
                    deleixo = malha(i,j,4); % derivada da cc de newmann cohecida
                    if ( x_ponto == 0 && y_ponto ~= H)
                        % parede esquerda
                        psi_pontoaolado =  malha(i, j+1, 5);
                        psi_pontoantes_y = malha(i-1, j, 5);
                        psi_pontodepois_y = malha(i+1, j, 5);
                        % funcao recebe o ponto ao lado no eixo que se faz
                        % taylor, ponto antes no outro eixo, ponoto depois
                        % no outro eixo, a derivada conhecida por newmann,
                        % a direcao, que �  1 pois � taylor para ponto
                        % posterior.
                        novo = psi_newmann_paredes(psi_pontoaolado, psi_pontoantes_y, psi_pontodepois_y, deleixo , 1, dx);
                        malha(i, j, 5) = relaxa(novo, velho, lambda_psi);
                    elseif (x_ponto == width && y_ponto ~= H) 
                        %parede direita
                        psi_pontoaolado = malha(i, j-1, 5);
                        psi_pontoantes_y = malha(i-1, j, 5);
                        psi_pontodepois_y = malha(i+1, j, 5);

                        novo = psi_newmann_paredes(psi_pontoaolado, psi_pontoantes_y, psi_pontodepois_y, deleixo , 0, dx);
                        malha(i, j, 5) = relaxa(novo, velho, lambda_psi);
                    elseif (y_ponto == H && x_ponto ~= 0 && x_ponto ~= width) 
                        %parede de cima
                        psi_pontoaolado = malha(i-1, j, 5);
                        psi_pontoantes_x = malha(i, j-1, 5);
                        psi_pontodepois_x = malha(i, j+1, 5);

                        novo = psi_newmann_paredes(psi_pontoaolado, psi_pontoantes_x, psi_pontodepois_x, deleixo , 0, dy);
                        malha(i, j, 5) = relaxa(novo, velho, lambda_psi);

                    elseif (x_ponto == 0 && y_ponto == H)
                        % forquilha, ou quina, em cima do lado esquerdo
                        
                        % tive que fazer isso pq eu nao consegui designar 2
                        % valores pra um ponto s� na matriz de cc.
                        valor_borda_cc_x = malha(i-1,j,4); 
                        valor_borda_cc_y = malha(i,j+1,4);
                        
                        psi_pontoaolado_x =  malha(i, j+1, 5);
                        psi_pontoaolado_y = malha(i-1, j, 5);
                        % funcao que recebe o vlaor ao lado nos dois eixos,
                        % a condicao de contorno ao lado nos dois eixos, a
                        % direcao, que nesse caso se refere ao Taylor no
                        % eixo x, pois no eixo y � sempre 0 ( taylor para
                        % ponto anterior).
                        novo = psi_newmann_forquilha(psi_pontoaolado_x, psi_pontoaolado_y, valor_borda_cc_x, valor_borda_cc_y, 1, dx);
                        malha(i, j, 5) = relaxa(novo, velho, lambda_psi);
                    else 
                       % forquilha, ou quina de cima e na direita
                       valor_borda_cc_x = malha(i-1,j,4);
                       valor_borda_cc_y = malha(i,j-1,4);
                       psi_pontoaolado_x =  malha(i, j-1, 5);
                       psi_pontoaolado_y = malha(i-1, j, 5);
                       
                       novo = psi_newmann_forquilha(psi_pontoaolado_x, psi_pontoaolado_y, valor_borda_cc_x, valor_borda_cc_y, 0, dx);
                       malha(i, j, 5) = relaxa(novo, velho, lambda_psi);
                    end
                otherwise
                    % N�s de Pr� Contorno Irregular
  
                    if (x_ponto < d + L/2) % parte da esquerda
                         
                        if (malha(i, j+1, 3) == 4 || malha(i, j+1, 3) == 0.5)
                            % se o ponto que est� logo � direita dele n�o �
                            % dichelet
                            % ponto que s� sofre econdi��o irregular em y
                            psi_pontoaolado = malha(i+1, j, 5);
                            psi_pontoantes_x = malha(i, j-1, 5);
                            psi_pontodepois_x = malha(i, j+1, 5);
                            % calculo do a
                            a = abs((Yx_simple(x_ponto, L, d, h)- y_ponto)/dy);
                            % valor da cc de dirichelet
                            valor_borda_cc = malha(i-1,j,4);
                            % funcao que recebe o valor ao lado no eixo que
                            % se faz taylor, o valor antes no outro eixo, o
                            % valor depois no outro eixo, a letra (a ou b)
                            % nesse caso a, e o valor da borda de
                            % dirichelet
                            novo = psi_irregular_umeixo(psi_pontoaolado, psi_pontoantes_x, psi_pontodepois_x, a, valor_borda_cc);
                            malha(i, j, 5) = relaxa(novo, velho, lambda_psi);
                    
                        elseif (malha(i-1, j, 3) == 4|| malha(i-1, j, 3) == 0.5)
                            % ponto que s� precisa de irregular em x
                            psi_pontoaolado = malha(i, j-1, 5);
                            psi_pontoantes_y = malha(i-1, j, 5);
                            psi_pontodepois_y = malha(i+1, j, 5);
                            valor_borda_cc = malha(i,j+1,4);
                            %  calculo de b por trigonometria 
                            b = abs((centro_cir_x - sqrt( (r^2) - ((y_ponto-h)^2) ) - x_ponto )/dx);
                            
                            novo = psi_irregular_umeixo(psi_pontoaolado, psi_pontoantes_y, psi_pontodepois_y, b, valor_borda_cc);
                            malha(i, j, 5) = relaxa(novo, velho, lambda_psi);
                            
                        else 
                            % sofre irregularidade nos dois eixos
                            psi_pontoaolado_y = malha(i+1, j, 5);
                            valor_borda_cc = malha(i-1,j+1,4);
                            psi_pontoaolado_x =  malha(i, j-1, 5);
                            % calculo de a de de b
                            a = abs((Yx_simple(x_ponto, L, d, h)- y_ponto)/dy);
                            b = abs((centro_cir_x - sqrt( (r^2) - ((y_ponto-h)^2) ) - x_ponto )/dx);

                            
                            % funcao que recebe o valor do ponto ao lado
                            % nos dois eixos, a, b e a coondicao de controno,
                            % que ser� comum aos dois eixos
                            novo = psi_irregular_duplo(psi_pontoaolado_x, psi_pontoaolado_y, a, b, valor_borda_cc);
                            malha(i, j, 5) = relaxa(novo, velho, lambda_psi);
                              
                        end
        
                    else % parte a direita
                        % muito parecido com a aprte da esquerda, vai mudar
                        % o c�lculo de b, e os pontos ao lado no eixo x,
                        % que antes eram psi_pontoantes_x e agora vao ser psi_pontodepois_x
                        if (malha(i, j-1, 3) == 4|| malha(i, j-1, 3) == 0.5)
                           % ponto que s� precisa de irregular em y
                            psi_pontoaolado = malha(i+1, j, 5);
                            psi_pontoantes_x = malha(i, j-1, 5);
                            psi_pontodepois_x = malha(i, j+1, 5);
                            a = abs((Yx_simple(x_ponto, L, d, h)- y_ponto)/dy);
                            valor_borda_cc = malha(i-1,j,4);

                            novo = psi_irregular_umeixo(psi_pontoaolado, psi_pontoantes_x, psi_pontodepois_x, a, valor_borda_cc);
                            malha(i, j, 5) = relaxa(novo, velho, lambda_psi);
                            
                        elseif (malha(i-1, j, 3) == 4|| malha(i-1, j, 3) == 0.5)
                            % ponto que s� precisa de irregular em x
                            psi_pontoaolado = malha(i, j+1, 5);
                            psi_pontoantes_y = malha(i-1, j, 5);
                            psi_pontodepois_y = malha(i+1, j, 5);
                            valor_borda_cc = malha(i,j-1,4);
                            b = abs((-centro_cir_x - sqrt( (r^2) - ((y_ponto-h)^2) ) + x_ponto )/dx);
                            
                            novo = psi_irregular_umeixo(psi_pontoaolado, psi_pontoantes_y, psi_pontodepois_y, b, valor_borda_cc);
                            malha(i, j, 5) = relaxa(novo, velho, lambda_psi);
                            
                        else 
                            psi_pontoaolado_y = malha(i+1, j, 5);
                            valor_borda_cc = malha(i-1,j-1,4);
                            psi_pontoaolado_x = malha(i, j+1, 5);

                            a = abs((Yx_simple(x_ponto, L, d, h)- y_ponto)/dy);
                            b = abs((-centro_cir_x - sqrt( (r^2) - ((y_ponto-h)^2) ) + x_ponto )/dx);

                            novo = psi_irregular_duplo(psi_pontoaolado_x, psi_pontoaolado_y, a, b, valor_borda_cc);
                            malha(i, j, 5) = relaxa(novo, velho, lambda_psi);   
                        end
                    end
            end
        end
    end
    it = it + 1;
    % calculo do erro relativo
    e_psi = ((malha(:,:,5) - current_matrix_psi))./(malha(:,:,5) + 0.001);
    %  mmaximo do erro na matriz de erro
    max_e_psi = max(e_psi(:));
end

%%%%%%%%%% 1a) PLOTA DISTRIBUI��O DE PSI %%%%%%%%%%%%%%
figure(3)
surf(x, y, malha(:,:,5))
%view(0,90)
colorbar
title('Escoamento \psi ao longo do plano \it xy')
xlabel('x \it [m]') 
ylabel('y \it [m]') 
zlabel('\Psi')










%%%%%%%%%%% Campo de Velocidades  e Pressao %%%%%%%%%%

% index 6 - v_matrix - matriz com a componente vertical da velocidade
% index 7 - u_matrix -  matriz com a componente horizontal da velocidade
% index 8 - U_matrix - matriz com as velocidades absolutas
% index 9 - pvar_matrix - matriz com as diferen�as de press�o


% v = -delpsidelx

% u = delpsidlely


% U = sqrt(u^2 + v^2)

for i = 1:len_lines
    for j = 1:len_rows
        psi_ponto = malha(i,j,5);
        x_ponto = malha(i,j,1);
        y_ponto = malha(i,j,2);
        
        if (malha(i, j, 3) == 0 || malha(i, j, 3) == 0.5 )
            psi_pontodepois_y = malha(i+1, j, 5);
            if (y_ponto == 0)
                %bottom %dif progressiva em y
                malha(i, j, 7) = (psi_pontodepois_y - psi_ponto)/dy;
                malha(i, j, 8) = abs(malha(i, j, 7)); % pois u � zero
                % funcao que calcula a diferenca de press�o dado o valor da
                % velocidade absoluta no ponto e as constantes do ar
                malha(i, j, 9) = pressao_var(ro, yar, malha(i, j, 8));
            end
        
        elseif (malha(i, j, 3) == 1)
            %  ponto interno -> 1a dif central
            psi_pontoantes_x = malha(i, j-1, 5);
            psi_pontodepois_x = malha(i, j+1, 5);
            psi_pontoantes_y = malha(i-1, j, 5);
            psi_pontodepois_y = malha(i+1, j, 5);
            
            malha(i, j, 6) = -(psi_pontodepois_x - psi_pontoantes_x)/(2*dx);
            malha(i, j, 7) = (psi_pontodepois_y - psi_pontoantes_y)/(2*dy);
            malha(i, j, 8) = sqrt((malha(i, j, 6))^2 + (malha(i, j, 7))^2);
            malha(i, j, 9) = pressao_var(ro, yar, malha(i, j, 8));
              
        elseif (malha(i,j,3) == 3)
            if (( x_ponto == 0 && y_ponto ~= H) || (x_ponto == width && y_ponto ~= H))
                % parede esuqerda
                % condicao de cc de newmann em um eixo
                %  1a dif central n outro eixo
                psi_pontoantes_y = malha(i-1, j, 5);
                psi_pontodepois_y = malha(i+1, j, 5);
                
                % v eh zero pela cc
                malha(i, j, 7) = (psi_pontodepois_y - psi_pontoantes_y)/(2*dy);
                malha(i, j, 8) = abs(malha(i, j, 7)); % v � zero 
                malha(i, j, 9) = pressao_var(ro, yar, malha(i, j, 8));
                
            elseif (y_ponto == H && x_ponto ~= 0 && x_ponto ~= width) 
                % parede de cima, topo
                % condicao de cc de newmann em um eixo
                %  1a dif central n outro eixo
                psi_pontoantes_x = malha(i, j-1, 5);
                psi_pontodepois_x = malha(i, j+1, 5);
                
                malha(i, j, 6) = -(psi_pontodepois_x - psi_pontoantes_x)/(2*dx);
                malha(i, j, 7) = V; % condicao de contorno
                malha(i, j, 8) = sqrt((malha(i, j, 6))^2 + (malha(i, j, 7))^2);
                malha(i, j, 9) = pressao_var(ro, yar, malha(i, j, 8));
                
            else
                % top left corner || top right corner
                % v eh zero pela condi��o de contorno
                malha(i, j, 7) = V; % cc
                malha(i, j, 8) = abs(malha(i, j, 7));
                malha(i, j, 9) = pressao_var(ro, yar, malha(i, j, 8));
            end
            
        elseif (malha(i, j, 3) == 4)
            % n�s pr�  irregularidades
            if (x_ponto < d + L/2) % parte da esquerda
                % ponto que s� sofre irregularidade em y
                if (malha(i, j+1, 3) == 4 || malha(i, j+1, 3) == 0.5)
                    psi_pontoantes_x = malha(i, j-1, 5);
                    psi_pontodepois_x = malha(i, j+1, 5);
                    psi_pontoaolado = malha(i+1, j, 5);
                    a = abs((Yx_simple(x_ponto, L, d, h)- y_ponto)/dy);
                    valor_borda_cc = malha(i-1,j,4);
                    
                    malha(i, j, 6) = -(psi_pontodepois_x - psi_pontoantes_x)/(2*dx);
                    % fun��o que calcula a derivada num ponto pr��
                    % irregulridade, ela recebe o vaor no ponto, o valor no
                    % ponto ao lado que n�o � da borda, o valor da borda, a
                    % letra (a ou b), delta e a direcao. A dire��o nesse
                    % caso � zero, pois � para ponto anterior em y.,para
                    % chegar na borda irregular.
                    malha(i, j, 7) = irregular_umeixo_derivada(psi_ponto, psi_pontoaolado, valor_borda_cc, a, dy, 0);
                    malha(i, j, 8) = sqrt((malha(i, j, 6))^2 + (malha(i, j, 7))^2);
                    malha(i, j, 9) = pressao_var(ro, yar, malha(i, j, 8));
                                       
                elseif (malha(i-1, j, 3) == 4 || malha(i-1, j, 3) == 0.5)
                    % ponto que s� sofre irregularidade em x 
                    psi_pontoantes_y = malha(i-1, j, 5);
                    psi_pontodepois_y = malha(i+1, j, 5);
                    psi_pontoaolado = malha(i, j-1, 5);
                    
                    %  calculo  de b por trigonometria
                    b = abs((centro_cir_x- sqrt( (r^2) - ((y_ponto-h)^2) ) - x_ponto )/dx);
                    valor_borda_cc = malha(i,j+1,4);
                    
                    malha(i, j, 6) = -(irregular_umeixo_derivada(psi_ponto, psi_pontoaolado, valor_borda_cc, b, dx, 1)); 
                    malha(i, j, 7) = (psi_pontodepois_y - psi_pontoantes_y)/(2*dy); 
                    malha(i, j, 8) = sqrt((malha(i, j, 6))^2 + (malha(i, j, 7))^2);
                    malha(i, j, 9) = pressao_var(ro, yar, malha(i, j, 8));
                    
                else 
                    % irregular nos dois eixos
                    psi_pontoaolado_x =  malha(i, j-1, 5);
                    psi_pontoaolado_y = malha(i+1, j, 5);
                    a = abs((Yx_simple(x_ponto, L, d, h)- y_ponto)/dy);
                    b = abs((centro_cir_x- sqrt( (r^2) - ((y_ponto-h)^2) ) - x_ponto )/dx);
                    valor_borda_cc = malha(i-1,j+1,4);
                    
                    malha(i, j, 6) = -(irregular_umeixo_derivada(psi_ponto, psi_pontoaolado_x, valor_borda_cc, b, dx, 1)); 
                    malha(i, j, 7) = irregular_umeixo_derivada(psi_ponto, psi_pontoaolado_y, valor_borda_cc, a, dy, 0);
                    malha(i, j, 8) = sqrt((malha(i, j, 6))^2 + (malha(i, j, 7))^2);
                    malha(i, j, 9) = pressao_var(ro, yar, malha(i, j, 8));
                    
                end
            else % parte a direita
                if (malha(i, j-1, 3) == 4|| malha(i, j-1, 3) == 0.5)
                    % ponto que s� precisa de irregular em y 
                    psi_pontoantes_x = malha(i, j-1, 5);
                    psi_pontodepois_x = malha(i, j+1, 5);
                    psi_pontoaolado = malha(i+1, j, 5);
                    a = abs((Yx_simple(x_ponto, L, d, h)- y_ponto)/dy);
                    valor_borda_cc = malha(i-1,j,4);
                    
                    malha(i, j, 6) = -(psi_pontodepois_x - psi_pontoantes_x)/(2*dx);
                    malha(i, j, 7) = irregular_umeixo_derivada(psi_ponto, psi_pontoaolado, valor_borda_cc, a, dy, 0);
                    malha(i, j, 8) = sqrt((malha(i, j, 6))^2 + (malha(i, j, 7))^2);
                    malha(i, j, 9) = pressao_var(ro, yar, malha(i, j, 8));
                    
                elseif (malha(i-1, j, 3) == 4 || malha(i-1, j, 3) == 0.5)
                    % ponto que s� precisa de irregular em  x
                    psi_pontoantes_y = malha(i-1, j, 5);
                    psi_pontodepois_y = malha(i+1, j, 5);
                    psi_pontoaolado = malha(i, j+1, 5);
                    b = abs((-centro_cir_x- sqrt( (r^2) - ((y_ponto-h)^2) ) + x_ponto )/dx);
                    valor_borda_cc = malha(i,j-1,4);
                    
                    malha(i, j, 6) = -(irregular_umeixo_derivada(psi_ponto, psi_pontoaolado, valor_borda_cc, b, dx, 0)); %  conferir dps;
                    malha(i, j, 7) = (psi_pontodepois_y - psi_pontoantes_y)/(2*dy); 
                    malha(i, j, 8) = sqrt((malha(i, j, 6))^2 + (malha(i, j, 7))^2);
                    malha(i, j, 9) = pressao_var(ro, yar, malha(i, j, 8));
                    
                else 
                    % irregular nos dois eixos
                    psi_pontoaolado_x =  malha(i, j+1, 5);
                    psi_pontoaolado_y = malha(i+1, j, 5);
                    a = abs((Yx_simple(x_ponto, L, d, h)- y_ponto)/dy);
                    b = abs((-centro_cir_x- sqrt( (r^2) - ((y_ponto-h)^2) ) + x_ponto)/dx);
                    valor_borda_cc = malha(i-1,j-1,4);
                    
                    malha(i, j, 6) = -(irregular_umeixo_derivada(psi_ponto, psi_pontoaolado_x, valor_borda_cc, b, dx, 0)); %  conferir dps;
                    malha(i, j, 7) = irregular_umeixo_derivada(psi_ponto, psi_pontoaolado_y, valor_borda_cc, a, dy, 0);
                    malha(i, j, 8) = sqrt((malha(i, j, 6))^2 + (malha(i, j, 7))^2);
                    malha(i, j, 9) = pressao_var(ro, yar, malha(i, j, 8));
                end
            end
            
        end
        
    end
end

%%%%%%%%% PLOTA COMPONENTE VERTICAL DA VELOCIDADE (v)
figure(4)
surf(x, y, malha(:,:,6)) % v
%view(0,90)
colorbar
title('Componente \it j da velocidade (\itv) no plano \itxy')
xlabel('x \it [m]') 
ylabel('y \it [m]') 
zlabel('v \it [m/s]')

%%%%%%%% PLOTA COMPONENTE HORIZONTAL DA VELOCIDADE (u)
figure(5)
surf(x, y, malha(:,:,7)) % u
%view(0,90)
colorbar
title('Componente i da velocidade (\itu) no plano \itxy')
xlabel('x \it[m]') 
ylabel('y \it[m]') 
zlabel('u \it[m/s]')

%%%%%%%% 1b) PLOTA  VELOCIDADE ABSOLUTA (U) %%%%%%%%%%%
figure(6)
quiver(x, y, malha(:,:,7), malha(:,:,6))
title('Vetores de Velocidade (\itU) no plano \itxy')
xlabel('x \it[m]') 
ylabel('y \it[m]') 

figure(15)
surf(x, y, malha(:,:,8))
title('Velocidade absoluta (\itU) no plano \itxy')
colorbar
xlabel('x \it[m]') 
ylabel('y \it[m]') 
zlabel('|U| \it[m/s]')

%%%%%%% 1c) PLOTA VARIA��O DE PRESS�O (pvar) %%%%%%%%
figure(7)
surf(x, y, malha(:,:,9))
%view(0,90)
colorbar
title('Varia��o de press�o (\itpvar) no plano \itxy')
xlabel('x \it[m]') 
ylabel('y \it[m]') 
zlabel('pvar \it[Pa]')


%%%%%%%%%%%%%%% SETUP PARA PLOTAGEM DA PRESS�O NO TELHADO %%%%%%%%

%%%%%%%% os ifs e elseif s�o para selecionar apenas os pontos que est�o
%%%%%%%% acima do telhado, ous eja que o ponto logo abaixo dele faz parte
%%%%%%%% do pr�dio/galp�o, que � de condi��o de dirichelet

p_matrix = malha(:,:,9);
for i = 1:len_lines
    for j = 1:len_rows
         if (malha(i,j,3) == 4)
            % pontos pr� irregularidade
            if ((malha(i-1,j,3) == 0 || malha(i-1,j,3) ==  0.5)) 
                % pontos em cima do telhado
                ptelhado_matrix(i,j) = p_matrix(i,j);
            end
            
         % tem uma excess�o, que � o topo do telhado, em que o ponto
         % coincide certinho com a a borda de dirichelet (diricheletem cheio)
         % ennt�o o ponto que vai esta rlogo acima, na verdade � um ponto
         % interno
         elseif ( (i > 1) && (malha(i-1,j,3) == 0.5) )
             % ponto logo acima topo do telhado
             ptelhado_matrix(i,j) = p_matrix(i,j);
         end
    end
end

% pra transformar os valores d amtriz em um vetor de valores do telhado
columns_sum = sum(ptelhado_matrix);
ptelhado = columns_sum(columns_sum ~= 0);

m = 15:dx:21;
% polin�mio de segundo grau pra se encaixar nos pontos 
% s� para mostrar a tend�ncia dos pontos, pois a discretiza��o acaba tendo um
% pouco de efeito por isso n�o fica uma curva certinha. Especialmente bem
% no topo do telhado, que cai certinho na borda de dirichelet, ent�o a
% press�o acaba ficando menor nesse ponto.
p = polyfit(m,ptelhado,2);

%%%%%%%%%%%%%% 1d) PLOTA VARIA��O DE PRESS�O (pvar) NO TELHADO , AO LONGO DO EIXO X %%%%%%%%%%%%%
figure(8)
s = scatter(m, ptelhado);
text((18.5),-609.0838,'\leftarrow valor m�nimo(discreto): -609.0838 [Pa]) ')
s.LineWidth = 0.6;
s.MarkerEdgeColor = 'b';
s.MarkerFaceColor = [0 0.5 0.5];
title(' Varia��o de press�o (\itpvar) ao longo do telhado \itx')
xlabel('x \it[m]') 
ylabel('pvar \it[Pa]') 
hold on 

%%%%%% PLOTA CURVA DE TEND�NCIA DOS PONTOS
xlinha = 15:dx/8:21;
ylinha = polyval(p,xlinha);
plot(xlinha, ylinha);

legend({'\itPvar nos pontos (discretizado)','Tend�ncia dos pontos, aproxima��o por fun��o de 2^{o} grau'})

%%%%%%%% CALCULA FORCA VERTICAL RESULTANTE NO TELHADO %%%%%%%%%%%%%
% pressao media * area do telhada projetada em xz
% a press�o m�dia funciona porque os pontos est�o igualmente espa�ados em x
pressao_media = (sum(ptelhado))/num_points;
forca_vertical = pressao_media*area_telhado_projecaoxz;
forca_vertical


pressao_minima = min(ptelhado);
pressao_minima



%%%%%%%%%%%%% PARTE 2 - DISTRIBUICAO DE TEMPERATURA %%%%%%%%%%

% index 10 -> matriz de nos
% index 11 -> matriz de condicao de contorno
% index 12 -> matriz de Temperatura

max_e_T = 1;
lambda_T = 1.15;
contador = 1;
disp("Inciando Liebmann para a Temperatura")
while max_e_T > 0.01
    current_matrix_T = malha(:,:,12);
    for i = 1:len_lines          %len_lines
        for j = 1:len_rows       %len_rows
            velho = malha(i, j, 12);
            x_ponto = malha(i,j,1);
            y_ponto = malha(i,j,2);
            u = malha(i,j,7);
            v = malha(i,j,6);
            
            switch malha(i, j, 10)
                case 1
                    % pontos internos
                    % U = ui + vj
                    T_pontoantes_x = malha(i, j-1, 12);
                    T_pontodepois_x = malha(i, j+1, 12);
                    T_pontoantes_y = malha(i-1, j, 12);
                    T_pontodepois_y = malha(i+1, j, 12);
                    
                    % W eh uma cte pra esse caso
                    W = C2*(T_pontoantes_x + T_pontodepois_x + T_pontoantes_y + T_pontodepois_y);
                    if (malha(i,j, 7) > 0 && malha(i,j, 6) > 0)
                        % u > 0 e v > 0
                        novo = (W - C1*(-u*T_pontoantes_x -v*T_pontoantes_y))/( 2*C2 + C1*(u + v) );
                        
                    elseif (malha(i,j, 7) > 0 && malha(i,j, 6) < 0)
                        % u > 0 e v < 0
                        novo = (W - C1*(-u*T_pontoantes_x +v*T_pontodepois_y))/( 2*C2 + C1*(u - v) );
                    end
                    
                    malha(i, j, 12) = relaxa(novo, velho, lambda_T);
                case 0
                case 0.5
                case 3
                    % Pontos de condi��o de contorno de Newmann
                    deleixo = malha(i,j,11); % condicao de contorno de newmann
                    if (y_ponto == 0 && x_ponto ~= width)
                        % parte de baixo
                        
                        % taylor em y e dif central em x 
                        T_pontoantes_x = malha(i, j-1, 12);
                        T_pontodepois_x = malha(i, j+1, 12);
                        T_pontodepois_y = malha(i+1, j, 12);
                        
                        direcao = 1; %  taylor para ponto posterior
                        % u > 0 e v pode ser > 0 ou < 0
                        % essas condi��es vao ser verificadas dentro da
                        % fun��o
                        
                        % similar ao algoritmo anterior, a fun��o vai
                        % receber o valor ao lado do eixo em que se faz
                        % taylor, o valor antes no outro eixo, o valor
                        % depois no outro eixo, a derivada conhecida por
                        % newmann, a direcao, que nesse cao � 1, pois �
                        % taylor para ponto posterior; as constantes e a
                        % componente de velocidade no eixo que se faz
                        % taylor; e por �ltimo a compoennte de velocidade
                        % no outro eixo
                        novo = T_newmann_paredes(T_pontodepois_y, T_pontoantes_x, T_pontodepois_x, deleixo, direcao, dx, C1, C2, v, u);
                        malha(i, j, 12) = relaxa(novo, velho, lambda_T);
                    elseif (x_ponto == width && y_ponto ~= H && y_ponto ~= 0) 
                        % parede direita 
                        T_pontoantes_x = malha(i, j-1, 12);
                        T_pontoantes_y = malha(i-1, j, 12);
                        T_pontodepois_y = malha(i+1, j, 12);
                        
                        direcao = 0; % taylor para ponto anterior
                        % u > 0 e v < 0
                        
                        novo = T_newmann_paredes(T_pontoantes_x, T_pontoantes_y, T_pontodepois_y, deleixo, direcao, dx, C1, C2, u, v);
                        malha(i, j, 12) = relaxa(novo, velho, lambda_T);
                    elseif (y_ponto == H && x_ponto ~= width) 
                        %top
                        T_pontoantes_y = malha(i-1, j, 12);
                        T_pontoantes_x = malha(i, j-1, 12);
                        T_pontodepois_x = malha(i, j+1, 12);
                        
                        direcao = 0; %taylor para ponto anterior
                        % u > 0 e v pode ser > 0 ou < 0
                        
                        novo = T_newmann_paredes(T_pontoantes_y, T_pontoantes_x, T_pontodepois_x, deleixo, direcao, dx, C1, C2, v, u);
                        malha(i, j, 12) = relaxa(novo, velho, lambda_T);
                    elseif (x_ponto == width && y_ponto == 0)
                        % bottom right corner
                        T_pontoantes_x = malha(i, j-1, 12);
                        T_pontodepois_y = malha(i+1, j, 12);
                        
                        delx = malha(i+1,j,11); % valor da borda tem que fazer isso pq eu nao consegui designar um 2 valores pra um ponto
                        dely = malha(i,j-1,11);
                        direcao = 1; % taylor posterior
                        % u > 0 e v < 0
                        
                        % funcoa que recebe o valor ao lado dos dois
                        % eixos, as derivadas conhecidas por newmann nos
                        % dois eixos, as constantes e u e v
                        novo = T_newmann_forquilha (T_pontoantes_x, T_pontodepois_y, delx, dely, direcao, dx, C1, C2, u, v);
                        malha(i, j, 12) = relaxa(novo, velho, lambda_T);
                    else 
                        % top right corner
                        T_pontoantes_y = malha(i-1, j, 12);
                        T_pontoantes_x = malha(i, j-1, 12);
                        
                        delx = malha(i-1,j,11);
                        dely = malha(i,j-1,11);
                        direcao = 0;
                        % u > 0 e v < 0
                        
                        % funcoa que recebe o valor ao lado dos dois
                        % eixos, as derivadas conhecidas por newmann nos
                        % dois eixos, as constantes e u e v
                        novo = T_newmann_forquilha (T_pontoantes_x, T_pontoantes_y, delx, dely, direcao, dx, C1, C2, u, v);
                        malha(i, j, 12) = relaxa(novo, velho, lambda_T);
                    end
                    
                otherwise
                    % Pontos Pre Contorno Irregular
                    T_pontoantes_x = malha(i, j-1, 12);
                    T_pontodepois_x = malha(i, j+1, 12);
                    T_pontoantes_y = malha(i-1, j, 12);
                    T_pontodepois_y = malha(i+1, j, 12);
                   
                    if (x_ponto < d + L/2) % parte da esquerda
                        % sentido_vel vai servir pras fun��es saberem que eu estou num
                        % ponto em que a v > 0. Pois muda o MDF.
                        sentido_vel = 1; % u > 0 e v > 0
                        if (malha(i, j+1, 10) == 4 || malha(i, j+1, 10) == 0.5)
                            % ponto que s� sofre irregularidade em y
                            a = abs((Yx_simple(x_ponto, L, d, h)- y_ponto)/dy);
                            valor_borda_cc = malha(i-1,j,11);
                            
                            % func�o que recebe o valor ao lado do eixo em
                            % que sofre irregularidade; o valor antes no
                            % outro eixo; o valor depois no outro eixo, a
                            % letra (a ou b), nesse caso a; o valor da
                            % condi��o de controno da borda irregular; as
                            % constantes; a componente da velocidade no
                            % eixo em que se faz taylor; a componente da
                            % velocidade no outro eixo e o sentido da
                            % velocidade v.
                            novo = T_irregular_umeixo(T_pontodepois_y, T_pontoantes_x, T_pontodepois_x, a, valor_borda_cc, C1, C2, v, u, sentido_vel);
                            malha(i, j, 12) = relaxa(novo, velho, lambda_T);
                            
                        elseif (malha(i-1, j, 10) == 4|| malha(i-1, j, 10) == 0.5)
                            % ponto que s� sofe irregularidade em x
                            b = abs((centro_cir_x- sqrt( (r^2) - ((y_ponto-h)^2) ) - x_ponto )/dx);
                            valor_borda_cc = malha(i,j+1,11);
                            
                            novo =  T_irregular_umeixo(T_pontoantes_x, T_pontoantes_y, T_pontodepois_y, b, valor_borda_cc, C1, C2, u, v, sentido_vel);
                            malha(i, j, 12) = relaxa(novo, velho, lambda_T);
                        else 
                            % ponto que sofre irregularidade nos dois
                            % eixos.
                            
                            a = abs((Yx_simple(x_ponto, L, d, h)- y_ponto)/dy);
                            b = abs((centro_cir_x- sqrt( (r^2) - ((y_ponto-h)^2) ) - x_ponto )/dx);
                            valor_borda_cc = malha(i-1,j+1,11);
                            
                            
                            % fun��o que recebe o valor ao lado no eixo x e
                            % o valor ao lado no eixo y; o valor da
                            % condi��o de contorno da borda(que � igal para
                            % os dois); as constantes; u e v.
                            novo = T_irregular_duplo( T_pontoantes_x, T_pontodepois_y, a, b, valor_borda_cc, C1, C2, u, v);
                            malha(i, j, 12) = relaxa(novo, velho, lambda_T);
                        end
        
                    else % parte a direita
                        % muito parecido com a aprte da esquerda, vai mudar
                        % o c�lculo de b, e os pontos ao lado no eixo x,
                        % que antes eram psi_pontoantes_x e agora vao ser psi_pontodepois_x
                        % Agora o sentido_vel tamb�m muda pra zero,pois v<0
                        sentido_vel = 0; % u > 0  e v < 0
                        if (malha(i, j-1, 10) == 4 || malha(i, j-1, 10) == 0.5)
                           % ponto que s� sofre irregulridade em y
                            a = abs((Yx_simple(x_ponto, L, d, h)- y_ponto)/dy);
                            valor_borda_cc = malha(i-1,j,11);
                            
                            novo = T_irregular_umeixo(T_pontodepois_y, T_pontoantes_x, T_pontodepois_x, a, valor_borda_cc, C1, C2, v, u, sentido_vel);
                            malha(i, j, 12) = relaxa(novo, velho, lambda_T);
                            
                        elseif (malha(i-1, j, 10) == 4|| malha(i-1, j, 10) == 0.5)
                            % ponto que s� precisa de irregularidade em x
                            valor_borda_cc = malha(i,j-1,11);
                            b = abs((-centro_cir_x- sqrt( (r^2) - ((y_ponto-h)^2) ) + x_ponto )/dx);
                            
                            novo =  T_irregular_umeixo(T_pontodepois_x, T_pontoantes_y, T_pontodepois_y, b, valor_borda_cc, C1, C2, u, v, sentido_vel);
                            malha(i, j, 12) = relaxa(novo, velho, lambda_T);
                            
                        else 
                            valor_borda_cc = malha(i-1,j-1,11);
                            a = abs((Yx_simple(x_ponto, L, d, h)- y_ponto)/dy);
                            b = abs((-centro_cir_x- sqrt( (r^2) - ((y_ponto-h)^2) ) + x_ponto )/dx);
                            
                            novo = T_irregular_duplo( T_pontodepois_x, T_pontodepois_y, a, b, valor_borda_cc, C1, C2, u, v);
                            malha(i, j, 12) = relaxa(novo, velho, lambda_T);   
                        end
                    end
            end
        end
    end
    contador = contador + 1;
    e_T = ((malha(:,:,12) - current_matrix_T))./(malha(:,:,12) + 0.001);
    max_e_T = max(e_T(:));
end


%%%%%%%%%%%%%%%%%%% 2a) PLOTA A DISTRIBUI��O DE TEMPERATURA %%%%%%%%%%%%
figure(9)
surf(x, y, malha(:,:,12))
%view(0,90)
colorbar
title(' Distribui��o de Temperatura no plano \itxy')
xlabel('x \it[m]') 
ylabel('y \it[m]') 
zlabel('T \it[C^{o}]')


%%%%%%%%%%%%%%%%%%%%%% 2b) C�LCULO CALOR TROCADO (W) %%%%%%%%%%%%%%%%%



% dA = dr*l % diferencial de �rea � igual ao diferencial de
% arco*comprimento pois comprimento � fixo.

% Tirando as constantes da integral, temos que calcular
%(delTdex,detTdely)*( normal_i, normal_j)*dr para cada ponto

% integrador vai ser um acumulador que vai somar todas as parcelas
integrador = 0;
% para cada ponto ser� medido um arco no sentido hor�rio saindo de 0 graus
% com a horizontal

% e a medi��o do dr vai ser feita com a difere�a do arco atual com o arco
% anterior

arco_horario_atual = 0;
arco_horario_anterior = 0;
for i = 1:len_lines
    for j = 1:len_rows
        if ( (malha(i,j,1) == d || malha(i,j,1) == d + L) && ( malha(i,j,10) == 0 || malha(i,j,10) == 0.5 ) )
            % pontos ao lado da parede do predio
             dparede = dx;
             if (malha(i,j-1,10) == 1)                
                %parede esquerda
                T_pontoantes_x = malha(i, j-1, 12);
                valor_borda_cc = malha(i,j+1,11);
                normal_i = -1;
                normal_j = 0;
                
                delTdelx = (valor_borda_cc - T_pontoantes_x)/(2*dx);
                delTdely = 0;
                integrador = integrador + (delTdelx*normal_i + delTdely*normal_j)*dparede;
             elseif (malha(i,j+1,10) == 1)
                %parede direita
                T_pontodepois_x = malha(i, j+1, 12);
                valor_borda_cc = malha(i,j-1,11);
                normal_i = 1;
                normal_j = 0;
                
                delTdelx = (T_pontodepois_x - valor_borda_cc)/(2*dx);
                delTdely = 0;
                integrador = integrador + (delTdelx*normal_i + delTdely*normal_j)*dparede;
             end
        elseif (malha(i,j,10) == 4)
            if ((malha(i-1,j,10) == 0 || malha(i-1,j,10) ==  0.5))
                % ponto logo acima do telhado
                x_ponto = malha(i,j,1);
                y_ponto = malha(i,j,2);
                T_ponto = malha(i,j,12);
                T_pontoantes_x = malha(i, j-1, 12);
                T_pontodepois_x = malha(i, j+1, 12);
                T_pontodepois_y = malha(i+1, j, 12);
                valor_borda_cc = malha(i-1,j,11);
                
                % calcula o valor de y no telhado pela equa��o do telhado
                y_telhado = Yx_simple(x_ponto, L, d, h);
                
                %origem no centro da circunferencia
                % calcula o versor normal
                modulo_vetor = sqrt( (x_ponto - centro_cir_x)^2 + (y_telhado - centro_cir_y)^2 );
                normal_i = (x_ponto - centro_cir_x)/modulo_vetor;
                normal_j = (y_telhado - centro_cir_y)/modulo_vetor;
                
                if (x_ponto < d + L/2) % parte esquerda
                    %  angulo
                    teta = atan(abs(normal_j/normal_i)); % medido em relacao a horizontal
                    % arco horario
                    arco_horario_atual = teta*r;
                    %  dr
                    darco = arco_horario_atual - arco_horario_anterior;
                    if (malha(i, j+1, 10) == 4 || malha(i, j+1, 10) == 0.5)
                        % ponto que s� sofre irregularidade em y
                        a = abs((Yx_simple(x_ponto, L, d, h)- y_ponto)/dy);
                        direcao = 0; % taylor para ponto anterior para chegar na irregularidade
                        
                        % calcula as derivadas no ponto.
                        
                        % No eixo que tem
                        % irregularidade usa a fun��o que aplica taylor, e
                        % elimina o termo da derivada segunda (somando dois
                        % taylors, um multiplicado por -a^2).
                        
                        %No outro eixo calcula por 1a dif central
                        delTdelx = (T_pontodepois_x - T_pontoantes_x)/(2*dx);
                        delTdely = irregular_umeixo_derivada(T_ponto, T_pontodepois_y, valor_borda_cc, a, dy, direcao);
                        % no final soma ao integrador o valor da parcela
                        % correpondente ao dr
                        integrador = integrador + (delTdelx*normal_i + delTdely*normal_j)*darco;
                        
                    else
                        % ponto que sofre irregularidade nos dois eixos
                        a = abs((Yx_simple(x_ponto, L, d, h)- y_ponto)/dy);
                        b = abs((centro_cir_x- sqrt( (r^2) - ((y_ponto-h)^2) ) - x_ponto )/dx);
                        direcao_x = 1;
                        direcao_y = 0;
                        
                        % calcul as derivadas por taylor 
                        delTdelx = irregular_umeixo_derivada(T_ponto, T_pontoantes_x, valor_borda_cc, b, dx, direcao_x);
                        delTdely = irregular_umeixo_derivada(T_ponto, T_pontodepois_y, valor_borda_cc, a, dy, direcao_y);
                        
                        % no final soma ao integrador o valor da parcela
                        % correpondente ao dr
                        integrador = integrador + (delTdelx*normal_i + delTdely*normal_j)*darco;

                    end

                else  % parte esquerda
                    teta = atan(normal_j/normal_i); % medido em relacao a horizontal
                    arco_horario_atual = (pi - teta)*r;
                    darco = arco_horario_atual - arco_horario_anterior;
                    if (malha(i, j+1, 10) == 4 || malha(i, j+1, 10) == 0.5)
                        % ponto que s� sofre irregularidade em y 
                        a = abs((Yx_simple(x_ponto, L, d, h)- y_ponto)/dy);
                        direcao = 0; % taylor para ponto anterior para chegar na irregularidade
                        
                        delTdelx = (T_pontodepois_x - T_pontoantes_x)/(2*dx);
                        delTdely = irregular_umeixo_derivada(T_ponto, T_pontodepois_y, valor_borda_cc, a, dx, direcao);
                        
                        integrador = integrador + (delTdelx*normal_i + delTdely*normal_j)*darco;
                        
                    else % ponto que precisa de irregular nos dois eixos
                        a = abs((Yx_simple(x_ponto, L, d, h)- y_ponto)/dy);
                        b = abs((centro_cir_x- sqrt( (r^2) - ((y_ponto-h)^2) ) - x_ponto )/dx);
                        direcao_x = 0;
                        direcao_y = 0;
                        
                        delTdelx = irregular_umeixo_derivada(T_ponto, T_pontodepois_x, valor_borda_cc, b, dx, direcao_x);
                        delTdely = irregular_umeixo_derivada(T_ponto, T_pontodepois_y, valor_borda_cc, a, dy, direcao_y);
                        
                        integrador = integrador + (delTdelx*normal_i + delTdely*normal_j)*darco;

                    end 
                end
            end
            
        elseif  ( malha(i,j,1) == d + L/2 && malha(i,j,10) == 0.5 )
            % excess�o
            % ponto bem acima do topo do telhado
            % ponto interior 
            x_ponto = malha(i,j,1);
            y_ponto = malha(i,j,2);
            T_ponto = malha(i,j,12);
            T_pontoantes_x = malha(i, j-1, 12);
            T_pontodepois_x = malha(i, j+1, 12);
            T_pontodepois_y = malha(i+1, j, 12);
            valor_borda_cc = malha(i-1,j,11);
            % versor n = versor j
            normal_i = 0;
            normal_j = 1;
            teta = pi/2; 
            arco_horario_atual = (pi*r)/2;
            darco = arco_horario_atual - arco_horario_anterior;
            
            %1a dif centrais
            delTdelx = (T_pontodepois_x - T_pontoantes_x)/(2*dx);
            delTdely = (T_pontodepois_y - valor_borda_cc)/(2*dx);
            
            integrador = integrador + (delTdelx*normal_i + delTdely*normal_j)*darco;

         end
         %  atuliza arco
         arco_horario_anterior = arco_horario_atual;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%% 2b) CALOR TROCADO (W) %%%%%%%%%%%%%%%%%%%%
calor_trocado = -kar*l*integrador;
calor_trocado


%%%%%%%%%%%%%%%%%%%%% FUN��ES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% calcula variacao de pressao dada velocidade absoluta e ctes
function variacao_pressao = pressao_var (ro, yar, U)
    variacao_pressao = (ro*((yar - 1)/yar))*(-(U^2)/2);
end

% Para Temperatura, calcula o valor, para pontos de quina, onde tem bordas
% de newmann nos dois eixos, recebe os pontos ao lado do ponto analisado,
% as derivadas de newmann conhecidas, direcao, ctes e u e v
% foi feito expansao em taylor para as achar as segundas derivadas e depois
% isolou o Tij, a cara da equa��o nao vai depender de u e v.
function T_ponto = T_newmann_forquilha (T_pontoaolado_eixo_x, T_pontoaoladoeixo_y, delx, dely, direcao, delta, C1, C2, u, v)
    %em x vai ser sempre direcao = 0 , taylor para ponto anterior
    if (direcao == 1) % falando de  y (tayor para ponto posterior)
        %parede de baixo ou esquerda
        F = 2*C2*(T_pontoaolado_eixo_x + delta*delx + T_pontoaoladoeixo_y - delta*dely);
    else % (taylor paraponto anterior)
        % parede de cima ou direita
        F = 2*C2*(T_pontoaolado_eixo_x + delta*delx + T_pontoaoladoeixo_y + delta*dely);
    end 
    
    T_ponto = (F - C1*(u*delx + v*dely))/(4*C2);
end 


% Para PSI, calcula o valor para pontos de quina, onde tem bordas de newmann nos dois eixos 
function psi_ponto = psi_newmann_forquilha (psi_pontoaolado_eixo_x, psi_pontoaoladoeixo_y, delx, dely, direcao, delta)
    % em y � sempre na mesma dire��o - 0, taylor para ponto anterior
    if (direcao == 1)  % falando de x
        % quina em cima na esquerda (taylor para ponto posterior)
        psi_ponto = (-delx*delta + dely*delta + psi_pontoaolado_eixo_x + psi_pontoaoladoeixo_y)/2;
    else % 0
        %quina em cima na direita (taylor para ponto anterior)
        psi_ponto = (+ delx*delta + dely*delta + psi_pontoaolado_eixo_x + psi_pontoaoladoeixo_y)/2;
    end 

end 


% Para Temperatura.
% calcula o valor para pontos de paredes, ous eja, quando tem um eixo com
% condi��o de newmann e outro eixo com difren�a central mesmo

% a constante Z(em relacao as velocidades) vai depender da dire��o em que se faz o taylor
% a cara da fun��o depende: se a componente da velocidade no outro
% eixo,(eixo que n�o se faz taylor � ) � > 0 ou < 0.
function T_ponto = T_newmann_paredes(T_pontoaolado_eixo, T_pontoantes_outroeixo, T_pontodepois_outroeixo, deleixo, direcao, delta, C1, C2, comp_velocidade_eixo, comp_velocidade_outro_eixo)
    if (direcao == 1)
        Z = C2*(T_pontoantes_outroeixo + T_pontodepois_outroeixo + 2*T_pontoaolado_eixo - delta*deleixo);
    else 
        Z = C2*(T_pontoantes_outroeixo + T_pontodepois_outroeixo + 2*T_pontoaolado_eixo + delta*deleixo);
    end
    
    if (comp_velocidade_outro_eixo > 0) 
        T_ponto = (Z - C1*(-comp_velocidade_outro_eixo*T_pontoantes_outroeixo + comp_velocidade_eixo*deleixo))/ ( 4*C2 + C1*comp_velocidade_outro_eixo );
    else 
        T_ponto = (Z - C1*(comp_velocidade_outro_eixo*T_pontodepois_outroeixo + comp_velocidade_eixo*deleixo))/ ( 4*C2 - C1*comp_velocidade_outro_eixo );
    end      
end

% Para PSI.
% calcula o valor para pontos de paredes, ous eja, quando tem um eixo com
% condi��o de newmann e outro eixo com difren�a central mesmo 
function psi_ponto = psi_newmann_paredes (psi_pontoaolado_eixo, psi_pontoantes_outroeixo, psi_pontodepois_outroeixo, deleixo, direcao, delta)
    % calcula aqui deldel por Taylor, sabendo deleixo pela condicao de contorno
    if (direcao == 1)
        % (psi_pontodepois_outroeixo - 2*psi_ponto +
        % psi_pontoantes_outroeixo)/2 + (2/dx^2)*(psi_pontoaolado_eixo -(deleixo*dx + 1)*psi_ponto)
        % isolando psi_ponto...
        
        % Taylor para frente
        psi_ponto = psi_pontoaolado_eixo/2 - (deleixo*delta)/2 + psi_pontodepois_outroeixo/4 + psi_pontoantes_outroeixo/4;
    else 
        % Taylor para tras
        psi_ponto = psi_pontoaolado_eixo/2 + (deleixo*delta)/2 + psi_pontodepois_outroeixo/4 + psi_pontoantes_outroeixo/4;
    end 
    
end 


% Usado para psi e temperatura.
% calcula a derivada em um eixo, num ponto pr� irregularidade. Como para
% chegar na equa��o final � preciso somar um taylor para tr�s com outro
% taylor para frente; sendo que o taylor que N�O � o que vai at� a borda
% irregular precisa ser multiplicado por -letra^2, para a segunda derivada
% sumir; a equa��o final acaba dependendo da dire��o desse desses taylors,
% se o tayylor at� a borda irregular � a para ponto posterior chamei de
% dire��o == , e se � para ponto anterior chamei de dire��o == 0
function valor_deleixo = irregular_umeixo_derivada(valor_ponto, valor_pontoaolado, valor_borda_cc, letra, dx, direcao)

    % em y direcao vai ser sempre 0, pois tem que fazer um taylor para tras
    %  pra chegar na borda
    if (direcao == 1) % ponto pre irregular na parte esquerda , taylor para ponto psterior pra chegar na borda irregular
        valor_deleixo = (valor_borda_cc - (letra^2)*valor_pontoaolado + (((letra^2) -  1)*valor_ponto))/((letra + letra^2)*dx);
    else  % ponto pre irregular na parte direita , taylor para ponto anterior para chegar na borda irregular 
        valor_deleixo = (valor_borda_cc - (letra^2)*valor_pontoaolado + (((letra^2) -  1)*valor_ponto))/((-letra - letra^2)*dx);
    end
end

% Para Temperatura.
% calcula o valor para pontos em que se observa apenas irregularidade em um
% eixo, e tem que ser feito taylor de irregularidade para achar as segunda
% derivada. E no outro eixo faz dif central mesmo.
% letra correpsonde � a ou b. A equa��o independe do lugar do ponto. 
% Pr�m  equa��o depende de v, v pode ser > 0 ou < 0. 

% Como a equa��o est� escrita gen�ricamente para qualquer eixo, � preciso
% identificar aguns casos. Ou as duas componentes s�o positivas. Ou uma
% delas � negativa (pois u � sempre > 0). Se uma delas � negativa, �
% preciso identificar qual delas, ou seja qual componente representa v na
% equa��o, para ent�o mudar a cara da equa��o de acordo.
function T_ponto = T_irregular_umeixo(T_pontoaolado_eixo, T_pontoantes_outroeixo, T_pontodepois_outroeixo, letra, valor_borda_cc, C1, C2, comp_velocidade_eixo, comp_velocidade_outroeixo, sentido_vel)
    % constante que independe de u,v e de ta do lado direito ou esquerdo do
    % telhado
    H = C2*( ( (2*valor_borda_cc)/(letra^2 + letra) ) + ( 2*T_pontoaolado_eixo/ (letra + 1) ) + T_pontoantes_outroeixo + T_pontodepois_outroeixo );
    
    if (sentido_vel == 1)
        % ponto do lado esquerdo do telhado, u > 0 e v > 0
        T_ponto = (  ( H -C1*(-comp_velocidade_eixo*valor_borda_cc -comp_velocidade_outroeixo*T_pontoantes_outroeixo) )/( (2*C2*(1+ letra)) + C1*(comp_velocidade_eixo + comp_velocidade_outroeixo) ) );
    % preciso identificar qual componente da velocidade � o v (vai ser ou a
    % componente do eixo em que se faz taylor ou a do outro eixo) porque
    % muda a equa��o
    elseif (comp_velocidade_eixo < 0) 
        % ponto do lado direito do telhado, u > 0, v < 0 e v = comp_velocidade_eixo
        T_ponto = (  ( H -C1*(comp_velocidade_eixo*T_pontoaolado_eixo - comp_velocidade_outroeixo*T_pontoantes_outroeixo) )/( (2*C2*(1+ letra)) + C1*(-comp_velocidade_eixo + comp_velocidade_outroeixo) ) );
    else 
        % ponto do lado direito do telhado, u > 0, v < 0 e v = comp_velocidade_outroeixo
        T_ponto = (  ( H -C1*(-comp_velocidade_eixo*valor_borda_cc + comp_velocidade_outroeixo*T_pontodepois_outroeixo) )/( (2*C2*(1+ letra)) + C1*(comp_velocidade_eixo - comp_velocidade_outroeixo) ) );
    end
    
end


% Para PSI. 
%Calcula o valor num ponto em que se observa irregularidade apenas em um
%eixo, ent�o � feita exans�o em taylor para irregularidade. No outro eixo faz segunda diferen�a central mesmo.
% Recebe o ponto ao lado do eixo emque est� fazendo taylor de
% irregularidade(N�O � O PONTO DA BORDA), o ponto antes no outro eixo, o
% ponto depois no outro eixo, a letra (a ou b) e o valor da borda irregular de
% dichelet 
function psi_ponto = psi_irregular_umeixo(psi_pontoaolado_eixo, psi_pontoantes_outroeixo, psi_pontodepois_outroeixo, letra, valor_borda_cc)
    psi_ponto = (psi_pontoantes_outroeixo + psi_pontodepois_outroeixo + (2*valor_borda_cc)/(letra^2 + letra) + (2*psi_pontoaolado_eixo)/(letra + 1))/((2/letra) + 2 );
end


% Para Temperatura.
% Calcula o valor parapontos com irregularidade nos dois eixos.]
% I � uma constante que n�o depende de u,v nem da posi��o do ponto
% Recebe o ponto ao lado dos dois eixos (QUE N�O S�O DA BORDA IRREGULAR),
% a, b, valor da bord de dichelet irregular do telhado, ctes,u e v
% o fato de v ser > 0 ou <0 vai mudar a cara da equa��o
function T_ponto = T_irregular_duplo( T_pontoaolado_x, T_pontoaolado_y, a, b, valor_borda_cc, C1, C2, u, v)
    % constante que nao depende de u, v nem se ta do lado esquerdo ou
    % direito do telhado
    I = 2*C2*( (valor_borda_cc/((b^2) + b)) +  (T_pontoaolado_x/ (b + 1)) + (valor_borda_cc/((a^2) + a)) +  (T_pontoaolado_y/ (a + 1))  );
    
    % u � sempre > 0
    if (v > 0)
        T_ponto = ( (I - C1*( -u*valor_borda_cc - v*valor_borda_cc ))/( 2*C2*((1/a)+ (1/b))  + C1*(u + v)) );
    else
        T_ponto = ( (I - C1*( -u*valor_borda_cc + v*T_pontoaolado_y ))/( 2*C2*((1/a)+ (1/b))  + C1*(u - v)) );
    end
end

% Para  PSI.
% Calcula o valor para um ponto com irregularidade nos dois eixos.
% Recebe o ponto ao lado dos dois eixos (QUE N�O S�O DA BORDA IRREGULAR),a,
% b e o valor da borda de dichelet irregular do telhado
function psi_ponto = psi_irregular_duplo( psi_pontoaolado_x, psipontoaolado_y, a, b, valor_borda_cc)
    % a sempre > 0
    % discretiza EDP por mdf pegando o deldeleixo de taylor
    psi_ponto = (valor_borda_cc/(b*(b+1)) + psi_pontoaolado_x/(b+1) + valor_borda_cc/(a*(a+1)) + psipontoaolado_y/(a+1))/(1/b + 1/a);
end

% aplica sobrerelaxa��o
function novo = relaxa(valor_novo, valor_velho, lambda)
    novo = lambda*valor_novo + (1 - lambda)*valor_velho;
end

% calcula o Y do predio/galpao, dado X. � utiizado a f�rmula do enunciado.
% Aqui o resultado � matricial
function Yx = Yx_predio(x, Lmatrix, dmatrix, h)
    Yx = (sqrt((Lmatrix./2).^2 - (x - dmatrix -(Lmatrix./2)).^2) + h);
end

% calcula o Y do predio/galpao, dado X. � utiizado a f�rmula do enunciado.
% Aqui o resultado � N�O � matricial.
function Yx_notmatrix = Yx_simple(x, L, d, h)
    Yx_notmatrix = (sqrt((L/2)^2 - (x - d -(L/2))^2) + h);
end


% Fun��o que identifica os tipos de n�s de interesse no grid,e atribui um
% valor para cada ponto em outra matriz fornecida. � usada na cria��o das
% matrizesde n�s, condi��es de contorno e matriz inicial
function matrix = Condicoes_T(matrix, x, y, d, L, H, width, dx, Lmatrix, dmatrix, h, valor_preirregular, valor_predio, valor_bordadichelet, valor_cond_borda_dichelet_em_cheio, valor_bordanewmann)
    cond_predio = ( x >= d & x <= d + L & y <= Yx_predio(x, Lmatrix, dmatrix, h) );
    cond_borda_newmann = ( y == H | x == width | ( y== 0 & (x < d | x > d+L)) ); 
    cond_borda_dichelet = ( x == 0 );
    cond_borda_dichelet_em_cheio = ( (x >= d & x <= d + L & y == Yx_predio(x, Lmatrix, dmatrix, h)) ); 
    cond_pe_irregular = ... 
        ((x >= d & x <= d+L) & y > Yx_predio(x, Lmatrix, dmatrix, h) & y < Yx_predio(x, Lmatrix, dmatrix, h) + dx)| ...
        (x >= d & x<= d + L/2 & y < Yx_predio(x + dx, Lmatrix, dmatrix, h)) | ...
        (x > d + L/2 & x <= d+L & y < Yx_predio(x - dx, Lmatrix, dmatrix, h));
    
    matrix(cond_pe_irregular) = valor_preirregular;
    matrix(cond_predio) = valor_predio;
    matrix(cond_borda_newmann) = valor_bordanewmann;
    matrix(cond_borda_dichelet) = valor_bordadichelet;
    matrix(cond_borda_dichelet_em_cheio) = valor_cond_borda_dichelet_em_cheio;
end


% Fun��o que identifica os tipos de n�s de interesse no grid,e atribui um
% valor para cada ponto em outra matriz fornecida. � usada na cria��o das
% matrizesde n�s, condi��es de contorno e matriz inicial
function matrix = Condicoes_psi(matrix, x, y, d, L, H, width, dx, Lmatrix, dmatrix, h, valor_preirregular, valor_predio, valor_bordadichelet, valor_cond_borda_dichelet_em_cheio, valor_bordanewmann_x, valor_bordanewmann_y)
    cond_predio = ( x >= d & x <= d + L & y <= Yx_predio(x, Lmatrix, dmatrix, h) );
    cond_borda_newmann_x = ( x == 0 | x == width); % o quadradinho nao aparece pra x == width | y == H
    cond_borda_newmann_y = ( y == H ); % o quadradinho nao aparece pra x == width | y == H
    cond_borda_dichelet = ( (y== 0 & (x < d | x > d+L)) );
    cond_borda_dichelet_em_cheio = ( (x >= d & x <= d + L & y == Yx_predio(x, Lmatrix, dmatrix, h)) ); 
    cond_pe_irregular = ... 
        ((x >= d & x <= d+L) & y > Yx_predio(x, Lmatrix, dmatrix, h) & y < Yx_predio(x, Lmatrix, dmatrix, h) + dx)| ...
        (x >= d & x<= d + L/2 & y < Yx_predio(x + dx, Lmatrix, dmatrix, h)) | ...
        (x > d + L/2 & x <= d+L & y < Yx_predio(x - dx, Lmatrix, dmatrix, h));
    matrix(cond_pe_irregular) = valor_preirregular;
    matrix(cond_predio) = valor_predio;
    matrix(cond_borda_newmann_x) = valor_bordanewmann_x;
    matrix(cond_borda_newmann_y) = valor_bordanewmann_y;
    matrix(cond_borda_dichelet) = valor_bordadichelet;
    matrix(cond_borda_dichelet_em_cheio) = valor_cond_borda_dichelet_em_cheio;
end










