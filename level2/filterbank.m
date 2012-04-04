function [ frameF ] = filterbank( frameT, frameType, winType )
%FilterBank

%{
    Calculates the MDCT coefficients for the given frame.

    Input:
        frameT: [2,2048], the given frame's samples
        frameType: string, the given frame's type
        winType: string, the type of the window to be applied

    Output:
        frameF: [2,1024], the MDCT coefficients for the given frame.
%}
    
    %calculate window according to the winType input
    if strcmp( winType, 'KAIZER' )
        windowS = KBDWindow( 256, 4 );
        windowL = KBDWindow( 2048, 6 );
    else
        windowS = sinewin( 256 )';
        windowL = sinewin( 2048 )';
    end
    windowS = [ windowS; windowS ];
    windowL = [ windowL; windowL ];
    
    %Applying window to given frame according to it's winType as dictated
    %by the protocol
    if strcmp( frameType, 'OLS' )
        frameT = frameT .* windowL;
        frameF = mdct4( frameT' )';
        
    elseif strcmp( frameType, 'ESH' )
        for i = 1:8
            % mdct4 uses column vectors as input and output
            subframe = frameT( :, 448 + ( i - 1 ) * 128 + 1 : 448 + ( i + 1 ) * 128 );
            subframe = subframe .* windowS;
            frameF( :, ( i - 1 ) * 128 + 1 : i * 128 ) = mdct4( subframe' )';
        end

        
    elseif strcmp( frameType, 'LSS' )
        window = [ windowL( :, 1:1024 ) ones( 2, 448 ) windowS( :, 129:256 ) zeros( 2, 448 ) ];
        frameT = frameT .* window;
        frameF = mdct4( frameT' )';
        
    else
        window = [ zeros( 2, 448 ) windowS( :, 1:128 ) ones( 2, 448 ) windowL( :, 1025:2048 ) ];
        frameT = frameT .* window;
        frameF = mdct4( frameT' )';
        
    end
end
