function [ T, P ] = psycho( frameF, frameType )
%Psychoacoustic Model

%{
    Calculates the energy spectrum of a frame as well as the hearing
    threshold.

    Input:
        frameF: [2,1024] the input frame, in frequency
        frameType: string, the type of the frame.
    Output:
        T: [2,5/40], the threshold.
        P: [43/70], the energy spectrum
%}
bjl = [ 0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 41 ...
            44 47 50 53 56 59 62 66 70 74 78 82 87 92 97 103 109 116 ...
            123 131 139 148 158 168 179 191 204 218 233 249 266 284 ...
            304 325 348 372 398 426 457 491 528 568 613 663 719 782 ...
            854 938 1023 ]; % +1 value, 1023
        
    bjs = [ 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 19 21 23 25 ...
            27 29 31 34 37 40 43 46 50 54 58 63 68 74 80 87 95 104 ...
            114 126 127 ]; % +1 value, 127
    
        
    Tql = [ 40.29 40.29 35.29 35.29 32.29 32.29 27.29 27.29 27.29 25.29 ...
            25.29 25.29 25.29 25.29 25.29 25.29 25.29 25.29 25.29 27.05 ...
            27.05 27.05 27.05 27.05 27.05 27.05 27.05 28.30 28.30 28.30 ...
            28.30 28.30 29.27 29.27 29.27 30.06 30.06 30.73 30.73 31.31 ...
            31.31 31.82 32.28 32.28 32.69 33.07 33.42 33.74 34.04 34.32 ...
            34.58 34.83 38.29 38.50 38.89 41.08 41.43 41.75 47.19 47.59 ...
            47.96 58.30 58.81 69.27 69.76 70.27 70.85 71.52 70.20 ];
        
    Tqs = [ 27.28 22.28 14.28 12.28 12.28 12.28 12.28 12.28 12.28 12.28 ...
            12.28 12.28 12.28 12.28 12.28 12.28 12.28 15.29 15.29 15.29 ...
            15.29 15.29 15.29 15.29 17.05 20.05 20.05 20.05 22.05 23.30 ...
            28.30 28.30 29.27 39.27 40.06 40.06 50.73 51.31 51.82 52.28 ...
            53.07 53.07 ];
        
        
    Bjl = [ 0.24 0.71 1.18 1.65 2.12 2.58 3.03 3.48 3.92 4.35 4.77 5.19 ...
            5.59 5.99 6.37 6.74 7.10 7.45 7.80 8.20 8.68 9.13 9.55 9.96 ...
            10.35 10.71 11.06 11.45 11.86 12.25 12.62 12.96 13.32 13.70 ...
            14.05 14.41 14.77 15.13 15.49 15.85 16.20 16.55 16.91 17.25 ...
            17.59 17.93 18.28 18.62 18.96 19.30 19.64 19.97 20.31 20.65 ...
            20.99 21.33 21.66 21.99 22.32 22.66 23.00 23.33 23.67 24.00 ...
            24.00 24.00 24.00 24.00 24.00 ];
    
    Bjs = [ 0.00 1.88 3.70 5.39 6.93 8.29 9.49 10.53 11.45 12.26 12.96 ...
            13.59 14.15 14.65 15.11 15.52 15.90 16.56 17.15 17.66 18.13 ...
            18.54 18.93 19.28 19.69 20.14 20.54 20.92 21.27 21.64 22.03 ...
            22.39 22.76 23.13 23.49 23.85 24.00 24.00 24.00 24.00 24.00 ...
            24.00 ];
    
    
    if strcmp( frameType, 'ESH' )
        bj = bjs;
        Tq = Tqs;
        Bj = Bjs;
    else
        bj = bjl;
        Tq = Tql;
        Bj = Bjl;
    end
    
    sqrs = frameF .^ 2;
    P = zeros( 1, size( bj, 2 ) - 1 );
    for j = 1:size(bj, 2) - 1
        P( j ) = sum( sqrs( bj( j ) + 1 : bj( j + 1 ) ) );
    end
    [frameF, ~] = TNS(frameF, frameType, P );
    
    sqrs = frameF .^ 2;
    for j = 1:size(bj,2) - 1
        P( j ) = sum( sqrs( bj( j ) + 1 : bj( j + 1 ) ) );
    end
    
    
    
    
    % Tspread calculation
    DB = ( Bj( 3:size( Bj, 2 ) ) - Bj( 1:size( Bj, 2 ) - 2 ) ) / 2;

    DB = [ 0 DB 0 ];
    
    
    sl = 30 * DB;
    sh = 20 * DB;
    
    Tsc = 10 * log( P ) - 29;
    Tsc = [0 Tsc ];
    T = max( Tsc( 2:size( Tsc, 2 ) ), Tsc( 1:size( Tsc, 2 ) - 1 ) - sh( 1:size( sh, 2 ) ) ); 
    T = [ T 0 ];
    Tspread = max( T( 1:size( T, 2 ) - 1 ), T( 2:size( T, 2 ) ) - sl( 1:size( sl, 2 ) ) ); 
    
    T = max( Tq, Tspread );
    
end