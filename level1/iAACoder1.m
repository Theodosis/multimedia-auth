function [ x ] = iAACoder1( AACSeq1, fNameOut )
%Level 1 - AAC Decoder implementation

%{
    Decodes the 2-channel input sound signal

    Input:
        AACSeq1: structure, encoded signal
        fNameOut: string, wav output file's name
    Output:
        x: [ 2, size( signal ) ], the original sound signal
%}
    sound = zeros( 2, ( size( AACSeq1, 1 ) + 1 ) * 1024 );
    for i = 1:size( AACSeq1, 1 )
        frameT = iFilterbank( ...
            [ AACSeq1( i, 1 ).FrameF0; AACSeq1( i, 1 ).FrameF1 ], ...
            AACSeq1( i, 1 ).frameType, ...
            AACSeq1( i, 1 ).winType );
        sound( :, ( i - 1 ) * 1024 + 1 : i * 1024 ) = sound( :, ( i - 1 ) * 1024 + 1 : i * 1024 ) + frameT( :, 1:1024 );
        sound( :, i * 1024 + 1 : ( i + 1 ) * 1024 ) = frameT( :, 1025:2048 );
    end
    
    sound = sound( :, 1025:size( sound, 2 ) - 1024 );
    wavwrite( sound', 48000, 16, fNameOut );
    x = sound;
end
