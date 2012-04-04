function [frameFout, TNScoeffs] = TNS(frameFin, frameType, P)
%Temporal Noise Shaping (TNS)

%{
    Calculates and applies the TNS coefficients to the frame.

    Input:
        frameFin: [2, 1024], the signal's values in frequency
        frameType: string, the type of the frame
        P: [43/70], the energy spectrum
    Output:
        frameFout: The frame in frequency
        TNScoeffs: The TNS coefficients.
%}
    bj_long = [ 0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 41 ...
                44 47 50 53 56 59 62 66 70 74 78 82 87 92 97 103 109 116 ...
                123 131 139 148 158 168 179 191 204 218 233 249 266 284 ...
                304 325 348 372 398 426 457 491 528 568 613 663 719 782 ...
                854 938 1023 ];
    bj_short = [ 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 19 21 23 25 ...
                 27 29 31 34 37 40 43 46 50 54 58 63 68 74 80 87 95 104 ...
                 114 126 127 ];
             
   
    if strcmp( frameType, 'ESH' )
        bj = bj_short;
    else
        bj = bj_long;
    end
    Sw = zeros( 1, bj( size( bj, 2 ) ) + 1 );
    % vectors normalization

    for j = 1:size(bj,2) - 1
        Sw( bj( j ) + 1 : bj( j + 1 ) ) = sqrt( P( j ) );
    end
    
    for k = bj( size( bj, 2 ) ) : -1 : 1 
        Sw(k) = (Sw(k) + Sw(k + 1))/2; 
    end
    for k = 2 : bj( size( bj, 2 ) ) + 1
        Sw(k) = (Sw(k) + Sw(k - 1))/2; 
    end
    
    % step2 
    
    if strcmp( frameType, 'ESH' )
        for i = 1:8
            Xw = frameFin( :, ( i - 1 ) * 128 + 1: i * 128 ) ./ [ Sw; Sw ];
            [ a,~ ] = lpc( Xw', 4 );
            a = round( a * 10 ) / 10;
            a = a .* ( a <= 0.8 & a > -0.8 ) ...
                + ( a > 0.8 ) * 0.8 ...
                + ( a < -0.7 ) * ( - 0.7 );
            
            b = [ roots( a( 1, : ) ), roots( a( 2, : ) ) ]';
            b = b .* ( abs( b ) < 1 ) + ...
                b .* 0.99 .* ( abs( b ) >= 1 ) ./ abs( b + ( b == 0 ) );
            
            TNScoeffs( :, ( i - 1 ) * 5 + 1 : i * 5 ) = [ poly( b( 1, : ) ); poly( b( 2, : ) ) ] ./ 10; % devide with 10 due to poly's behaviour
            
            frameFout( :, ( i - 1 ) * 128 + 1 : i * 128 ) = [ ...
                filter( TNScoeffs( 1, ( i - 1 ) * 5 + 1:i * 5 ), 1, frameFin( 1, ( i - 1 ) * 128 + 1: i * 128 )' )'; ...
                filter( TNScoeffs( 2, ( i - 1 ) * 5 + 1:i * 5 ), 1, frameFin( 2, ( i - 1 ) * 128 + 1: i * 128 )' )' ...
            ];
        end
    
    % step 2
    else
        Xw( :, 1:size( frameFin, 2 ) ) = frameFin( :, 1:size( frameFin, 2 ) ) ./ [ Sw; Sw ];
    

        % linear prediction coefficients
        [ a,~ ] = lpc( Xw', 4 );
        % coefficients quantization
        a = round( a * 10 ) / 10;
        a = a .* ( a <= 0.8 & a > -0.8 ) ...
            + ( a > 0.8 ) * 0.8 ...
            + ( a < -0.7 ) * ( - 0.7 );

        % take the roots of the polynomial
        b = [ roots( a( 1, : ) ), roots( a( 2, : ) ) ]';
        % limit the roots in the unit circle
        
        b = b .* ( abs( b ) < 1 ) + ...
            b .* 0.99 .* ( abs( b ) >= 1 ) ./ abs( b + ( b == 0 ) ); % b == 0 ensures that no 0/0 occures
        
        % move back to the polynomial
        TNScoeffs = [ poly( b( 1, : ) ); poly( b( 2, : ) ) ] ./ 10; % devide with 10 due to poly's behaviour
        
        frameFout = [ filter( TNScoeffs( 1, : ), 1, frameFin( 1, : )' )'; filter( TNScoeffs( 2, : ), 1, frameFin( 2, : )' )' ];
    end
    
end