files = dir('*');
for i = 1:length(files)
    if ~files(i).isdir
        
        filename = files(i).name;
        %         [X,map] = dicomread(filename);
        %         x(i) = max(X(:));
        % Read the DICOM file
        dicomInfo = dicominfo(filename);
        dicomImage = dicomread(dicomInfo);
        
        % Modify values greater than 4000
        dicomImage(dicomImage > 4000) = 4000;
        
        % Save the modified DICOM file
        outputFileName = ['/bigvault/Projects/seeg_pointing/subject/subject27/CT_MRI/CT/CT_dcm/new/new_',filename];
        dicomwrite(dicomImage, outputFileName, dicomInfo, 'CreateMode', 'Copy');
    end
end

