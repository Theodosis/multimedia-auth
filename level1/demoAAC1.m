function [ SNR ] = demoAAC1( fnameIn, fnameOut )
%AAC Encoder/Decoder demonstration

%{
    Calculates the Signal-to-Noise Ratio (SNR) by encoding and decoding the
    signal

    Input:
        fNameIn: string, wav input file's name
        fNameOut: string, wav output file's name
    Output:
        SNR: num, Signal-to-Noise Ratio
%}

    a = AACoder1( fnameIn, 282624 );
    iAACoder1( a, fnameOut );
    
    input = wavread(fnameIn)';
    output = wavread(fnameOut)';

    input = input( :, 1:size( output, 2 ) );
    output = output( :, 1:size( output, 2 ) );
     
    input = sum( input, 1 );
    output = sum( output, 1 );
    noise = input - output;
    
    Asign = sum( input .^ 2, 2 );
    Anoise = sum( noise .^ 2, 2 );
    
    SNR = 10 * log10( Asign ./ Anoise );
    
end

