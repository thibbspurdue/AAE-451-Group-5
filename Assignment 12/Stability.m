%% Global Parameter Definition
g = 9.81;


%% Longitudinal Dynamic Stability
A = [Xu             ,  Xw             ,  0              ,-g;
     Zu             ,  Zw             ,  U0             , 0;
    (Mu + Mw_dot*Zu), (Mu + Mw_dot*Zw), (Mq + Mw_dot*U0), 0;
     0              ,  0              ,  1              , 0];

B = [X_de; Z_de; M_de+Mw_dot*Z_de; 0];


%Eigenvalues and Eigenvectors of A
[Eigenvectors, Eigenvalues] = eig(A);
fprintf("Here are the eigenvalues of the system:\n")
Eigenvalues = [Eigenvalues(1,1), Eigenvalues(2,2), Eigenvalues(3,3), Eigenvalues(4,4)]
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

% Display table
disp(ResultsTable)

%% Lateral Dynamic Stability
A = [ Yv,    Yp,    Yr - U0,   g;
      Lv,    Lp,    Lr,        0;
      Nv,    Np,    Nr,        0;
      0,     1,     0,         0 ];

B = [ Yda,   Ydr;
      Lda,   Ldr;
      Nda,   Ndr;
      0,     0 ];

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
is = find(abs(imag(Eigenvectors)) > 0);
i = is(1);
DR = [real(Eigenvalues(i)), abs(imag(Eigenvalues(i)))];
Eigenvectors(is) = [];

%spiral
[~, i] = min(abs(Eigenvectors));
S = real(Eigenvalues(i));
Eigenvectors(i) = [];

%roll
R = Eigenvalues(1);

% Create table
Mode = ["Dutch Roll"; "Spiral"; "Roll"];
Eigenvalue = [DR; S; R];
Natural_Frequency_rad_s = [norm(DR); "N/A"; "N/A"];
Damping_Ratio = [-DR(1)/norm(DR); "N/A"; "N/A"];
Time_to_double = ["N/A"; log(2)/S; log(2)/R];

ResultsTable = table(Mode, Eigenvalue_Real, Eigenvalue_Imag, ...
                     Natural_Frequency_rad_s, Damping_Ratio, Time_to_double);

% Display table
disp(ResultsTable)