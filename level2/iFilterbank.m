function [ frameT ] = iFilterbank(frameF, frameType,winType)
%Inverted FilterBank

%{
    Calculates the frame's samples using the MDCT coefficients.

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
        frameT = imdct4( frameF' )';
        frameT = frameT .* windowL;
        
        
    elseif strcmp( frameType, 'ESH' )
        frameT = zeros( 2, 1152 );
        %Applying window on each of the 50% overlapping subframes
        for i = 1:8
            subframe = imdct4( frameF( :, ( i - 1 ) * 128 + 1 : i * 128 )' )';
            subframe = subframe .* windowS;
            frameT( :, ( i - 1 ) * 128 + 1 : i * 128 ) = frameT( :, ( i - 1 ) * 128 + 1 : i * 128 ) + subframe( :, 1:128 );
            frameT( :, i * 128 + 1 : ( i + 1 ) * 128 ) = subframe( :, 129:256 );
        end
        frameT = [ zeros( 2, 448 ) frameT zeros( 2, 448 ) ];
            
    elseif strcmp( frameType, 'LSS' )
        window = [ windowL( :, 1:1024 ) ones( 2, 448 ) windowS( :, 129:256 ) zeros( 2, 448 ) ];
        frameT = imdct4( frameF' )';
        frameT = frameT .* window;
        
        
    else
        window = [ zeros( 2, 448 ) windowS( :, 1:128 ) ones( 2, 448 ) windowL( :, 1025:2048 ) ];
        frameT = imdct4( frameF' )';
        frameT = frameT .* window;
    
    end
end

