function [ win ] = KBDWindow( NN,a )
%Takes as input the length of the asking window and the constant a

%references on the web:
%http://en.wikipedia.org/wiki/Kaiser-Bessel_derived_(KBD)_window#Kaiser-Bes
%sel_derived_.28KBD.29_window
%http://en.wikipedia.org/wiki/Modified_Bessel_function#Modified_Bessel_func
%tions_:_I.CE.B1.2C_K.CE.B1

%On all the mathematical types on the above webpages we have to make
%some changes on the limits because the array pointers in matlab begin from 1.
%Also after test this function fulfills the  Princen-Bradley conditions.

N=NN/2;

for i=1:N
    num(i)=pi*a*sqrt(1-(2*(i-1)/(N-1)-1)^2);
end


%implentation of wn
for i=1:N
 w(i)=besselI0(num(i));
end
    
%implementation of dn
denominator=sqrt(sum(w));
for i=1:N
    tmp=sqrt(sum(w(1:i)));
    win(i)=tmp/denominator;
    win(NN-i+1)=win(i);
end
 win=win;

end