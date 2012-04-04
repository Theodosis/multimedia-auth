function [ frameFout ] = iTNS( frameFin,frameType,TNScoeffs )
%Inverted Temporal Noise Shaping (TNS)

%{
    Applies the reverse FIR filter

    Input:
        frameFin: [2, 1024], the signal's values in frequency
        frameType: string, the type of the frame
        TNScoeffs: The previously calculated coefficients of the filter
    Output:
        frameFout: The frame in frequency, after the application of the
        filter
%}
    if strcmp(frameType,'ESH')
        for i=1:8
            TNSFrame = TNScoeffs( :, ( i - 1 ) * 5 + 1 : i * 5 );
            frameFout( 1, ( i - 1 ) * 128 + 1 : i * 128 ) = filter( 1, TNSFrame( 1, : ), frameFin( 1, ( i - 1 ) * 128 + 1 : i * 128 ) );
            frameFout( 2, ( i - 1 ) * 128 + 1 : i * 128 ) = filter( 1, TNSFrame( 2, : ), frameFin( 2, ( i - 1 ) * 128 + 1 : i * 128 ) );
        end    
    else
        frameFout( 1, : ) = filter( 1, TNScoeffs( 1, : ), frameFin( 1, : ) );
        frameFout( 2, : ) = filter( 1, TNScoeffs( 2, : ), frameFin( 2, : ) );
    end
end