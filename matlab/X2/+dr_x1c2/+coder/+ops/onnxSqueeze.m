function [Y, numDimsY] = onnxSqueeze(X, ONNXAxes_, numDimsX_)
% Implements the ONNX Squeeze operator
%#codegen

% Copyright 2024 The MathWorks, Inc.

ONNXAxes = dr_x1c2.coder.ops.extractIfDlarray(ONNXAxes_);
numDimsX = dr_x1c2.coder.ops.extractIfDlarray(numDimsX_);

if numDimsX == 0
    Y = X;
    numDimsY = numDimsX;
else
    % Find the new ONNX shape
    curONNXShape = size(X, numDimsX:-1:1);
    numDimsY = numDimsX-numel(ONNXAxes);    
    if isempty(ONNXAxes)
        newONNXShape = curONNXShape(curONNXShape ~= 1);
    else
        coder.unroll();
        for i = 1:numel(ONNXAxes)
            if ONNXAxes(i)<0
                ONNXAxes(i) = ONNXAxes(i) + numDimsX;
            end
        end        
        newONNXShape = zeros(1, numDimsY, 'single');
        ito = 1;
        coder.unroll();
        for ifrom = 1:numDimsX
            if ~ismember(ifrom, ONNXAxes+1)
                newONNXShape(ito) = curONNXShape(ifrom);
                ito = ito+1;
            end
        end
    end    
    if isempty(newONNXShape)
        Y = X;
        numDimsY = 0;
    else
        newMShape = [fliplr(newONNXShape) ones(1, 2-numDimsY)];    % Append 1's to shape if numDims<2
        Y         = reshape(X, newMShape);
        numDimsY  = numel(newONNXShape);
    end
end
end