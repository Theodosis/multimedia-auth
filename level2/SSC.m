function [ frameType ] = SSC( nextFrameT, prevFrameType )
%Sequence Segmentation Control

%{
    Computes the current frame's type using the previous frame's type and the
    esimated next frame's type

    Input:
        nextFrameT: [2,2048], the next frame's samples
        prevFrameType: string, the previous frame's type

    Output:
        frameType: string, the calculated current frame's type
%}

    
    if strcmp( 'LSS', prevFrameType )
        frameType = 'ESH';
        return;
    elseif strcmp( 'LPS', prevFrameType )
        frameType = 'OLS';
        return;
    end

    % step 1
    % Defining the filter
    H = [ 0.7548 -0.7548; 1 -0.5095 ];
    
    
    % Aplying the filter
    % The filter operates on columns
    nextFrameT = filter( H( 1, : ), H( 2, : ), nextFrameT' )';


    % step 2 and 3
    s = zeros( 2, 8 );
    ds = zeros( 2, 8 );
    squares = nextFrameT( :, 577:1600 ) .^ 2;
    
    % calculate s and ds vectors
    for i = 1:8
        s( :, i ) = sum( squares( :, ( i - 1 ) * 128 + 1 : i * 128 ), 2 );
    end
    for i = 2:8
        ds( :, i ) = s( :, i ) * i ./ sum( s( :, 1:i-1 ), 2 );
    end
    

    % calculate next frame's type for both channels
    for i = 1:2
        if( sum( s( i, : ) > 0.001 & ds( i, : ) > 10 ) )
            nextFrameTypePerChannel( i, : ) = 'ESH';
        else
            nextFrameTypePerChannel( i, : ) = 'OLS';
        end


        if( strcmp( nextFrameTypePerChannel( i, : ), prevFrameType ) )
            frameTypePerChannel( i, : ) = nextFrameTypePerChannel( i, : );
        else
            if( strcmp( prevFrameType, 'OLS' ) )
                frameTypePerChannel( i, : ) = 'LSS';
            else
                frameTypePerChannel( i, : ) = 'LPS';
            end
        end
    end
    
    
    % we now know the types of the current frame for each channel.
    % Applying Pinakas 1 to determine the final frame type.
    if strcmp( frameTypePerChannel( 1, : ), 'ESH' ) || strcmp( frameTypePerChannel( 2, : ), 'ESH' ) 
        frameType = 'ESH';
    elseif strcmp( frameTypePerChannel( 1, : ), frameTypePerChannel( 2, : ) )
        frameType = frameTypePerChannel( 1, : );
    elseif strcmp( frameTypePerChannel( 1, : ), 'LSS' ) && strcmp( frameTypePerChannel( 2, : ), 'LPS' ) || ...
           strcmp( frameTypePerChannel( 1, : ), 'LPS' ) && strcmp( frameTypePerChannel( 2, : ), 'LSS' ) 
        frameType = 'ESH';
    elseif strcmp( frameTypePerChannel( 1, : ), 'LSS' ) || strcmp( frameTypePerChannel( 2, : ), 'LSS' ) 
        frameType = 'LSS';
    else
        frameType = 'LPS';
    end
end