function [ AACSeq2 ] = AACoder2( fNameIn, N )
%Level 2 - AAC Encoder implementation

%{
    Encodes the 2-channel input sound signal

    Input:
        fNameIn: string, wav input file's name
        N: int, the number of samples to be read
    Output:
        Seq1: structure, encoded signal
%}
    
    sound = wavread( fNameIn )';
    %Sample number must be a 2048-multiple
    N = N - ( mod( N,2048 ) );
    
    %Zero padding. Append and prepend half a frame of zeros to the signal samples' sequence
    sound = [ zeros( 2, 1024 ) sound( :, 1:N ) zeros( 2, 1024 ) ];
    N = N + 2048;

    AACSeq2 = struct('frameType', {},  'winType', {}, 'TNScoeffs', {}, 'T', {}, 'FrameF0', {}, 'FrameF1', {} );
    
    size = N / 1024 - 1; %2 * ( N / 2048 ) - 1;

    prevType = 'OLS';
    for i= 1:size - 1
        prevType= SSC ( sound( :, i * 1024 + 1 : ( i + 2 ) * 1024 ), prevType );
        AACSeq2(i,1).frameType = prevType;
        AACSeq2(i,1).winType = 'sinusoid';
        
        frameF = filterbank( sound( :, ( i - 1 ) * 1024 + 1 : ( i + 1 ) * 1024 ), AACSeq2( i ).frameType, AACSeq2( i ).winType );
        
        [ T, P ] = psycho( frameF, AACSeq2(i,1).frameType );
        [ frameF, AACSeq2(i,1).TNScoeffs ] = TNS( frameF, AACSeq2(i,1).frameType, P );
        
        AACSeq2(i,1).FrameF0 = frameF( 1,: );
        AACSeq2(i,1).FrameF1 = frameF( 2,: );
        
        AACSeq2(i,1).T = T;
    end

end
