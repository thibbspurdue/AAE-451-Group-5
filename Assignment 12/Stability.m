%% Global Parameter Definition
digits(64);
g = 9.81;
U0 = 306.3;

%% XFLR Control Matricies for 40 degrees new, #22 of longitudinal modes

A_long = [
   -0.00792849    0.123578      0          -9.81;
   -0.276748     -0.28584     72.138        0;
   -1.87822e-11  -2.47477    -12.8682       0;
    0             0           1             0
];

A_lat = [
   -1.21963e-05    0.0497228   -74.2284     9.81;
   -1.21189e+16   -3.53078e+17  5.49944e+16 0;
    4.15983e+15    1.21195e+17 -1.88769e+16 0;
    0              1            0            0
];


B_long = [
   -0.717243;
  -12.20328;
 -824.8833;
    0
];

B_lat = [
   -5.055286e-13;
   -5353071;
    1837454;
    0
];
%% Parameters for 40 degrees deflection
% 
% 
% %Longitudinal derivatives
% Xu=     -367.81         
% Cxu=    -0.12461
% Xw=      1332.5         
% Cxa=     0.45142
% Zu=     -4214.1         
% Czu=   0.0053347
% Zw=     -4541.3         
% CLa=      1.5385
% Zq=      -27404         
% CLq=      2.3062
% Mu=  -5.999e-06         
% Cmu= -2.5243e-10
% Mw=  1.0443e+05         
% Cma=      4.3943
% Mq=  4.8534e+05         
% Cmq=       5.073
% %Neutral Point position= -30.42611 m
% 
% 
% %Lateral derivatives
% Yv=     -5.8309         
% CYb=  -0.0019754
% Yp=       495.4         
% CYp=    0.019516
% Yr=       320.2         
% CYr=    0.012614
% Lv=     -5162.7         
% Clb=    -0.10169
% Lp=  1.1913e+05         
% Clp=     0.27285
% Lr=       62087         
% Clr=      0.1422
% Nv=     -430.24         
% Cnb=  -0.0084743
% Np=  -1.828e+05         
% Cnp=    -0.41867
% Nr=      -31491         
% Cnr=   -0.072124
% 
% %Control derivatives 
% Xde=      -14778        
% CXde=    -0.11615
% Yde= -1.0962e-08        
% CYde= -8.6158e-14
% Zde=      -82466        
% CZde=    -0.64814
% Lde=  3.2273e-07        
% CLde=  1.4747e-13
% Mde=  5.2896e+05        
% CMde=     0.51635
% Nde=  5.3879e-07        
% CNde=   2.462e-13

%% Parameters for tail

% %Longitudinal derivatives
% Xu=     -20.667         
% Cxu= -0.00030677
% Xw=      120.69         
% Cxa=   0.0017914
% Zu=     -184.27         
% Czu=  1.5731e-05
% Zw=      -28083         
% CLa=     0.41684
% Zq= -1.5862e+05         
% CLq=     0.58486
% Mu=  0.00013569         
% Cmu=  2.5015e-10
% Mw= -1.2355e+06         
% Cma=     -2.2778
% Mq= -6.9167e+06         
% Cmq=     -3.1676
% %Neutral Point position=  36.56606 m
% 
% 
% %Lateral derivatives
% Yv=      15.589         
% CYb=   0.0002314
% Yp=     -1037.7         
% CYp=   -0.001791
% Yr=      8.6903         
% CYr=  1.4999e-05
% Lv=      -15031         
% Clb=   -0.012972
% Lp=  -3.317e+06         
% Clp=    -0.33285
% Lr=  4.9216e+05         
% Clr=    0.049386
% Nv=      -30207         
% Cnb=   -0.026068
% Np=      -47165         
% Cnp=  -0.0047328
% Nr= -1.4933e+05         
% Cnr=   -0.014984
% 
% %Control derivatives 
% Xde=      5737.4        
% CXde=  8.6561e-05
% Yde=  4.1821e-07        
% CYde=  6.3095e-15
% Zde= -1.5265e+07        
% CZde=     -0.2303
% Lde=  0.00039538        
% CLde=  3.4681e-13
% Mde= -4.1577e+08        
% CMde=     -0.7791
% Nde=  0.00015451        
% CNde=  1.3553e-13
%% Adjustment for Aeilerons and Rudder
%Added ones for aeilerons because they are elevator and aeileron
Yda = Yde;
Lda = Lde;
Nda = Nde;

%We have no rudder
Ydr = 0;
Ldr = 0;
Ndr = 0;
%% Longitudinal Dynamic Stability
% A = [Xu             ,  Xw             ,  0              ,-g;
%      Zu             ,  Zw             ,  U0             , 0;
%     (Mu + Mw*Zu), (Mu + Mw*Zw), (Mq + Mw*U0), 0;
%      0              ,  0              ,  1              , 0];
% 
% B = [Xde; Zde; Mde+Mw*Zde; 0];
A = A_long; B = B_long;

disp(ctrb(A,B));
disp(rank(ctrb(A,B)));
if(rank(sym(ctrb(A,B))) ~= 4)
    fprintf("Fuck we are uncontrollable\n")
else
    fprintf("We ball\n")
end

%Eigenvalues and Eigenvectors of A
[Eigenvectors, Eigenvalues] = eig(A);
fprintf("Here are the eigenvalues of the system:\n")
Eigenvalues = [Eigenvalues(1,1), Eigenvalues(2,2), Eigenvalues(3,3), Eigenvalues(4,4)]
E1 = Eigenvalues;
fprintf("Here are the eigenvectors of the system:\n")
disp(Eigenvectors);

eig1 = [real(Eigenvalues(1)), imag(Eigenvalues(1))];
eig2 = [real(Eigenvalues(3)), imag(Eigenvalues(3))];
%Phugoid, Short period determination
if imag(Eigenvalues(1)) > imag(Eigenvalues(3))
    SP = eig1; PH = eig2;
    SP_vectors = Eigenvectors(:,1:2); PH_vectors = Eigenvectors(:,3:4);
else
    PH = eig1; SP = eig2;
    PH_vectors = Eigenvectors(:,1:2); SP_vectors = Eigenvectors(:,3:4);
end

fprintf("The Phugoid mode eigenvalues are %0.4f +/- %0.4fi\n", PH(1), PH(2))
fprintf("The natural frequency of the Phugoid mode is %0.3f rad/s\n", norm(PH))
fprintf("The damping ratio of the Phugoid mode is %0.3f rad/s\n", -PH(1)/norm(PH))
fprintf("The period of the Phugoid mode is %0.3f seconds\n", 2*pi/PH(2))
fprintf("The Short Period mode eigenvalues are %0.4f +/- %0.4fi\n", SP(1), SP(2))
fprintf("The natural frequency of the Short Period mode is %0.3f rad/s\n", norm(SP))
fprintf("The damping ratio of the Short Period mode is %0.3f rad/s\n", -SP(1)/norm(SP))
fprintf("The period of the Short Period mode is %0.3f seconds\n", 2*pi/SP(2))


% Compute Phugoid values
ph_eig_real = PH(1);
ph_eig_imag = PH(2);
ph_wn = norm(PH);
ph_zeta = -PH(1)/ph_wn;
ph_T = 2*pi/PH(2);

% Compute Short Period values
sp_eig_real = SP(1);
sp_eig_imag = SP(2);
sp_wn = norm(SP);
sp_zeta = -SP(1)/sp_wn;
sp_T = 2*pi/SP(2);

% Create table
Mode = ["Phugoid"; "Short Period"];
Eigenvalue_Real = [ph_eig_real; sp_eig_real];
Eigenvalue_Imag = [ph_eig_imag; sp_eig_imag];
Natural_Frequency_rad_s = [ph_wn; sp_wn];
Damping_Ratio = [ph_zeta; sp_zeta];
Period_s = [ph_T; sp_T];

ResultsTable = table(Mode, Eigenvalue_Real, Eigenvalue_Imag, ...
                     Natural_Frequency_rad_s, Damping_Ratio, Period_s);

% % Display table
% disp(ResultsTable)
% 
% %Eigenvalues and Eigenvectors of A
% [Eigenvectors, Eigenvalues] = eig(A);
% fprintf("Here are the eigenvalues of the system:\n")
% Eigenvalues = [Eigenvalues(1,1), Eigenvalues(2,2), Eigenvalues(3,3), Eigenvalues(4,4)]
% fprintf("Here are the eigenvectors of the system:\n")
% disp(Eigenvectors);
% 
% eig1 = [real(Eigenvalues(1)), imag(Eigenvalues(1))];
% eig2 = [real(Eigenvalues(3)), imag(Eigenvalues(3))];
% %Spiral, Roll, Dutch Roll modes
% 
% %dutch roll
% is = find(abs(imag(Eigenvalues)./real(Eigenvalues)) > 0);
% i = is(1);
% DR = Eigenvalues(i); %[real(Eigenvalues(i)) + imag(Eigenvalues(i))]
% Eigenvalues(is) = [];
% 
% %spiral
% [~, i] = min(abs(Eigenvalues));
% S = real(Eigenvalues(i));
% Eigenvalues(i) = [];
% 
% %roll
% R = Eigenvalues(1);
% 
% % Create table
% Mode = ["Dutch Roll"; "Spiral"; "Roll"];
% Eigenvalue = [DR; S; R];
% Natural_Frequency_rad_s = [norm(DR); "N/A"; "N/A"];
% Damping_Ratio = [-DR(1)/norm(DR); "N/A"; "N/A"];
% Time_to_double = ["N/A"; log(2)/S; log(2)/R];
% 
% ResultsTable = table(Mode, Eigenvalue, ...
%                      Natural_Frequency_rad_s, Damping_Ratio, Time_to_double);
% 
% % Display table
% disp(ResultsTable)

%% Lateral Dynamic Stability
% A = [ Yv,    Yp,    Yr - U0,   g;
%       Lv,    Lp,    Lr,        0;
%       Nv,    Np,    Nr,        0;
%       0,     1,     0,         0 ];
% 
% B = [ Yda,   Ydr;
%       Lda,   Ldr;
%       Nda,   Ndr;
%       0,     0 ];

A = A_lat; B = B_lat;

disp(ctrb(A,B));
disp(rank(ctrb(A,B)));
if(rank(sym(ctrb(A,B)) )~= 4)
    fprintf("Fuck we are uncontrollable\n")
else
    fprintf("We ball\n")
end

%Eigenvalues and Eigenvectors of A
[Eigenvectors, Eigenvalues] = eig(A);
fprintf("Here are the eigenvalues of the system:\n")
Eigenvalues = [Eigenvalues(1,1), Eigenvalues(2,2), Eigenvalues(3,3), Eigenvalues(4,4)]
fprintf("Here are the eigenvectors of the system:\n")
disp(Eigenvectors);

eig1 = [real(Eigenvalues(1)), imag(Eigenvalues(1))];
eig2 = [real(Eigenvalues(3)), imag(Eigenvalues(3))];
%Spiral, Roll, Dutch Roll modes

%dutch roll
is = find(abs(imag(Eigenvalues)) > 0);
i = is(1);
DR = Eigenvalues(i); %[real(Eigenvalues(i)) + imag(Eigenvalues(i))]
Eigenvalues(is) = [];

%spiral
[~, i] = min(abs(Eigenvalues));
S = real(Eigenvalues(i));
Eigenvalues(i) = [];

%roll
R = Eigenvalues(1);

% Create table
Mode = ["Dutch Roll"; "Spiral"; "Roll"];
Eigenvalue = [DR; S; R];
Natural_Frequency_rad_s = [norm(DR); "N/A"; "N/A"];
Damping_Ratio = [-DR(1)/norm(DR); "N/A"; "N/A"];
Time_to_double = ["N/A"; log(2)/S; log(2)/R];

ResultsTable = table(Mode, Eigenvalue, ...
                     Natural_Frequency_rad_s, Damping_Ratio, Time_to_double);

% Display table
disp(ResultsTable)