function handles = AlgMeasureCorrelation(handles)

% Help for the Measure Correlation module:
% Category: Measurement
% 
% Given two or more images, calculates the correlation between the
% pixel intensities. The correlation can be measured for the entire
% images, or individual correlation measurements can be made for each
% individual object, as defined by another module.
%
% See also ALGMEASUREAREAOCCUPIED,
% ALGMEASUREAREASHAPEINTENSTXTR,
% ALGMEASUREINTENSITYTEXTURE,
% ALGMEASURETOTALINTENSITY.

% CellProfiler is distributed under the GNU General Public License.
% See the accompanying file LICENSE for details.
% 
% Developed by the Whitehead Institute for Biomedical Research.
% Copyright 2003,2004,2005.
% 
% Authors:
%   Anne Carpenter <carpenter@wi.mit.edu>
%   Thouis Jones   <thouis@csail.mit.edu>
%   In Han Kang    <inthek@mit.edu>
%
% $Revision$

% PROGRAMMING NOTE
% HELP:
% The first unbroken block of lines will be extracted as help by
% CellProfiler's 'Help for this analysis module' button as well as
% Matlab's built in 'help' and 'doc' functions at the command line. It
% will also be used to automatically generate a manual page for the
% module. An example image demonstrating the function of the module
% can also be saved in tif format, using the same name as the
% algorithm (minus Alg), and it will automatically be included in the
% manual page as well.  Follow the convention of: purpose of the
% module, description of the variables and acceptable range for each,
% how it works (technical description), info on which images can be 
% saved, and See also CAPITALLETTEROTHERALGORITHMS. The license/author
% information should be separated from the help lines with a blank
% line so that it does not show up in the help displays.  Do not
% change the programming notes in any modules! These are standard
% across all modules for maintenance purposes, so anything
% module-specific should be kept separate.

% PROGRAMMING NOTE
% DRAWNOW:
% The 'drawnow' function allows figure windows to be updated and
% buttons to be pushed (like the pause, cancel, help, and view
% buttons).  The 'drawnow' function is sprinkled throughout the code
% so there are plenty of breaks where the figure windows/buttons can
% be interacted with.  This does theoretically slow the computation
% somewhat, so it might be reasonable to remove most of these lines
% when running jobs on a cluster where speed is important.
drawnow

%%%%%%%%%%%%%%%%
%%% VARIABLES %%%
%%%%%%%%%%%%%%%%

% PROGRAMMING NOTE
% VARIABLE BOXES AND TEXT: 
% The '%textVAR' lines contain the text which is displayed in the GUI
% next to each variable box. The '%defaultVAR' lines contain the
% default values which are displayed in the variable boxes when the
% user loads the algorithm. The line of code after the textVAR and
% defaultVAR extracts the value that the user has entered from the
% handles structure and saves it as a variable in the workspace of
% this algorithm with a descriptive name. The syntax is important for
% the %textVAR and %defaultVAR lines: be sure there is a space before
% and after the equals sign and also that the capitalization is as
% shown.  Don't allow the text to wrap around to another line; the
% second line will not be displayed.  If you need more space to
% describe a variable, you can refer the user to the help file, or you
% can put text in the %textVAR line above or below the one of
% interest, and do not include a %defaultVAR line so that the variable
% edit box for that variable will not be displayed; the text will
% still be displayed. CellProfiler is currently being restructured to
% handle more than 11 variable boxes. Keep in mind that you can have
% several inputs into the same box: for example, a box could be
% designed to receive two numbers separated by a comma, as long as you
% write a little extraction algorithm that separates the input into
% two distinct variables.  Any extraction algorithms like this should
% be within the VARIABLES section of the code, at the end.

%%% Reads the current algorithm number, since this is needed to find the
%%% variable values that the user entered.
CurrentAlgorithm = handles.currentalgorithm;
CurrentAlgorithmNum = str2double(handles.currentalgorithm);

%textVAR01 = Enter the names of each image type to be compared. If a box is unused, leave "/"
%defaultVAR01 = OrigBlue
Image1Name = char(handles.Settings.Vvariable{CurrentAlgorithmNum,1});

%textVAR02 = All pairwise comparisons will be performed.
%defaultVAR02 = OrigGreen
Image2Name = char(handles.Settings.Vvariable{CurrentAlgorithmNum,2});

%textVAR03 = 
%defaultVAR03 = OrigRed
Image3Name = char(handles.Settings.Vvariable{CurrentAlgorithmNum,3});

%textVAR04 = 
%defaultVAR04 = /
Image4Name = char(handles.Settings.Vvariable{CurrentAlgorithmNum,4});

%textVAR05 = 
%defaultVAR05 = /
Image5Name = char(handles.Settings.Vvariable{CurrentAlgorithmNum,5});

%textVAR06 = 
%defaultVAR06 = /
Image6Name = char(handles.Settings.Vvariable{CurrentAlgorithmNum,6});

%textVAR07 = 
%defaultVAR07 = /
Image7Name = char(handles.Settings.Vvariable{CurrentAlgorithmNum,7});

%textVAR08 = 
%defaultVAR08 = /
Image8Name = char(handles.Settings.Vvariable{CurrentAlgorithmNum,8});

%textVAR09 = 
%defaultVAR09 = /
Image9Name = char(handles.Settings.Vvariable{CurrentAlgorithmNum,9});

%textVAR10 = What did you call the objects within which to compare the images?
%textVAR11 = Leave "/" to compare the entire images
%defaultVAR10 = /
ObjectName = char(handles.Settings.Vvariable{CurrentAlgorithmNum,10});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PRELIMINARY CALCULATIONS & FILE HANDLING %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
drawnow

if strcmp(Image1Name,'/') ~= 1
    try
        %%% Reads (opens) the image you want to analyze and assigns it to a variable.
        fieldname = ['', Image1Name];
        %%% Checks whether image has been loaded.
if isfield(handles.Pipeline, fieldname)==0,
            %%% If the image is not there, an error message is produced.  The error
            %%% is not displayed: The error function halts the current function and
            %%% returns control to the calling function (the analyze all images
            %%% button callback.)  That callback recognizes that an error was
            %%% produced because of its try/catch loop and breaks out of the image
            %%% analysis loop without attempting further modules.
            error(['Image processing was canceled because the Measure Correlation module could not find the input image.  It was supposed to be named ', Image1Name, ' but an image with that name does not exist.  Perhaps there is a typo in the name.'])
        end
        Image1 = handles.Pipeline.(fieldname);

        %%% Checks that the original image is two-dimensional (i.e. not a color
        %%% image), which would disrupt several of the image functions.
        if ndims(Image1) ~= 2
            error('Image processing was canceled because the Measure Correlation module requires an input image that is two-dimensional (i.e. X vs Y), but the image loaded does not fit this requirement.  This may be because the image is a color image.')
        end
    catch error(['There was a problem loading the image you called ', Image1Name, ' in the Measure Correlation module.'])
    end
end
%%% Repeat for the rest of the images.
if strcmp(Image2Name,'/') ~= 1
    try
        if isfield(handles.Pipeline, Image2Name) == 0
            error(['Image processing was canceled because the Measure Correlation module could not find the input image.  It was supposed to be named ', Image2Name, ' but an image with that name does not exist.  Perhaps there is a typo in the name.'])
        end
        Image2 = handles.Pipeline.(Image2Name);
        if ndims(Image2) ~= 2
            error('Image processing was canceled because the Measure Correlation module requires an input image that is two-dimensional (i.e. X vs Y), but the image loaded does not fit this requirement.  This may be because the image is a color image.')
        end
    catch error(['There was a problem loading the image you called ', Image2Name, ' in the Measure Correlation module.'])
    end
end
if strcmp(Image3Name,'/') ~= 1
    try
        if isfield(handles.Pipeline, Image3Name) == 0
            error(['Image processing was canceled because the Measure Correlation module could not find the input image.  It was supposed to be named ', Image3Name, ' but an image with that name does not exist.  Perhaps there is a typo in the name.'])
        end
        Image3 = handles.Pipeline.(Image3Name);
        if ndims(Image3) ~= 2
            error('Image processing was canceled because the Measure Correlation module requires an input image that is two-dimensional (i.e. X vs Y), but the image loaded does not fit this requirement.  This may be because the image is a color image.')
        end
    catch error(['There was a problem loading the image you called ', Image3Name, ' in the Measure Correlation module.'])
    end
end
if strcmp(Image4Name,'/') ~= 1
    try
        if isfield(handles.Pipeline, Image4Name) == 0
            error(['Image processing was canceled because the Measure Correlation module could not find the input image.  It was supposed to be named ', Image4Name, ' but an image with that name does not exist.  Perhaps there is a typo in the name.'])
        end
        Image4 = handles.Pipeline.(Image4Name);
        if ndims(Image4) ~= 2
            error('Image processing was canceled because the Measure Correlation module requires an input image that is two-dimensional (i.e. X vs Y), but the image loaded does not fit this requirement.  This may be because the image is a color image.')
        end
    catch error(['There was a problem loading the image you called ', Image4Name, ' in the Measure Correlation module.'])
    end
end
if strcmp(Image5Name,'/') ~= 1
    try
        if isfield(handles.Pipeline, Image5Name) == 0
            error(['Image processing was canceled because the Measure Correlation module could not find the input image.  It was supposed to be named ', Image5Name, ' but an image with that name does not exist.  Perhaps there is a typo in the name.'])
        end
        Image5 = handles.Pipeline.(Image5Name);
        if ndims(Image5) ~= 2
            error('Image processing was canceled because the Measure Correlation module requires an input image that is two-dimensional (i.e. X vs Y), but the image loaded does not fit this requirement.  This may be because the image is a color image.')
        end
    catch error(['There was a problem loading the image you called ', Image5Name, ' in the Measure Correlation module.'])
    end
end
if strcmp(Image6Name,'/') ~= 1
    try
        if isfield(handles.Pipeline, Image6Name) == 0
            error(['Image processing was canceled because the Measure Correlation module could not find the input image.  It was supposed to be named ', Image6Name, ' but an image with that name does not exist.  Perhaps there is a typo in the name.'])
        end
        Image6 = handles.Pipeline.(Image6Name);
        if ndims(Image6) ~= 2
            error('Image processing was canceled because the Measure Correlation module requires an input image that is two-dimensional (i.e. X vs Y), but the image loaded does not fit this requirement.  This may be because the image is a color image.')
        end
    catch error(['There was a problem loading the image you called ', Image6Name, ' in the Measure Correlation module.'])
    end
end
if strcmp(Image7Name,'/') ~= 1
    try
        if isfield(handles.Pipeline, Image7Name) == 0
            error(['Image processing was canceled because the Measure Correlation module could not find the input image.  It was supposed to be named ', Image7Name, ' but an image with that name does not exist.  Perhaps there is a typo in the name.'])
        end
        Image7 = handles.Pipeline.(Image7Name);
        if ndims(Image7) ~= 2
            error('Image processing was canceled because the Measure Correlation module requires an input image that is two-dimensional (i.e. X vs Y), but the image loaded does not fit this requirement.  This may be because the image is a color image.')
        end
    catch error(['There was a problem loading the image you called ', Image7Name, ' in the Measure Correlation module.'])
    end
end
if strcmp(Image8Name,'/') ~= 1
    try
        if isfield(handles.Pipeline, Image8Name) == 0
            error(['Image processing was canceled because the Measure Correlation module could not find the input image.  It was supposed to be named ', Image8Name, ' but an image with that name does not exist.  Perhaps there is a typo in the name.'])
        end
        Image8 = handles.Pipeline.(Image8Name);
        if ndims(Image8) ~= 2
            error('Image processing was canceled because the Measure Correlation module requires an input image that is two-dimensional (i.e. X vs Y), but the image loaded does not fit this requirement.  This may be because the image is a color image.')
        end
    catch error(['There was a problem loading the image you called ', Image8Name, ' in the Measure Correlation module.'])
    end
end
if strcmp(Image9Name,'/') ~= 1
    try
        if isfield(handles.Pipeline, Image9Name) == 0
            error(['Image processing was canceled because the Measure Correlation module could not find the input image.  It was supposed to be named ', Image9Name, ' but an image with that name does not exist.  Perhaps there is a typo in the name.'])
        end
        Image9 = handles.Pipeline.(Image9Name);
        if ndims(Image9) ~= 2
            error('Image processing was canceled because the Measure Correlation module requires an input image that is two-dimensional (i.e. X vs Y), but the image loaded does not fit this requirement.  This may be because the image is a color image.')
        end
    catch error(['There was a problem loading the image you called ', Image9Name, ' in the Measure Correlation module.'])
    end
end
if strcmp(ObjectName,'/') ~= 1
    %%% Retrieves the label matrix image that contains the 
    %%% segmented objects which will be used as a mask. Checks first to see
    %%% whether the appropriate image exists.
    fieldname = ['Segmented', ObjectName];
    %%% Checks whether the image exists in the handles structure.
if isfield(handles.Pipeline, fieldname)==0,
        error(['Image processing has been canceled. Prior to running the Measure Correlation module, you must have previously run an algorithm that generates an image with the primary objects identified.  You specified in the Measure Correlation module that the objects were named ', ObjectName, ' as a result of a previous algorithm, which should have produced an image called ', fieldname, ' in the handles structure.  The Measure Correlation module cannot locate this image.']);
    end
    MaskLabelMatrixImage = handles.Pipeline.(fieldname);

end

%%%%%%%%%%%%%%%%%%%%%
%%% IMAGE ANALYSIS %%%
%%%%%%%%%%%%%%%%%%%%%
drawnow

% PROGRAMMING NOTE
% TO TEMPORARILY SHOW IMAGES DURING DEBUGGING: 
% figure, imshow(BlurredImage, []), title('BlurredImage') 
% TO TEMPORARILY SAVE IMAGES DURING DEBUGGING: 
% imwrite(BlurredImage, FileName, FileFormat);
% Note that you may have to alter the format of the image before
% saving.  If the image is not saved correctly, for example, try
% adding the uint8 command:
% imwrite(uint8(BlurredImage), FileName, FileFormat);
% To routinely save images produced by this module, see the help in
% the SaveImages module.

%%% Starts out with empty variables.
ImageMatrix = [];
ImageNames = [];
%%% For each image, reshapes the image into a column of numbers, then
%%% places it as a column into the variable ImageMatrix.  Adds its name
%%% to the list of ImageNames, too.
if strcmp(Image1Name,'/') ~= 1
Image1Column = reshape(Image1,[],1);
     % figure, imshow(Image1Column), title('Image1Column'), colormap(gray)
ImageMatrix = horzcat(ImageMatrix,Image1Column);
ImageNames = strvcat(ImageNames,Image1Name); %#ok We want to ignore MLint error checking for this line.
end
if strcmp(Image2Name,'/') ~= 1
Image2Column = reshape(Image2,[],1);
ImageMatrix = horzcat(ImageMatrix,Image2Column);
ImageNames = strvcat(ImageNames,Image2Name); %#ok We want to ignore MLint error checking for this line.
end
if strcmp(Image3Name,'/') ~= 1
Image3Column = reshape(Image3,[],1);
ImageMatrix = horzcat(ImageMatrix,Image3Column);
ImageNames = strvcat(ImageNames,Image3Name); %#ok We want to ignore MLint error checking for this line.
end
if strcmp(Image4Name,'/') ~= 1
Image4Column = reshape(Image4,[],1);
ImageMatrix = horzcat(ImageMatrix,Image4Column);
ImageNames = strvcat(ImageNames,Image4Name); %#ok We want to ignore MLint error checking for this line.
end
if strcmp(Image5Name,'/') ~= 1
Image5Column = reshape(Image5,[],1);
ImageMatrix = horzcat(ImageMatrix,Image5Column);
ImageNames = strvcat(ImageNames,Image5Name); %#ok We want to ignore MLint error checking for this line.
end
if strcmp(Image6Name,'/') ~= 1
Image6Column = reshape(Image6,[],1);
ImageMatrix = horzcat(ImageMatrix,Image6Column);
ImageNames = strvcat(ImageNames,Image6Name); %#ok We want to ignore MLint error checking for this line.
end
if strcmp(Image7Name,'/') ~= 1
Image7Column = reshape(Image7,[],1);
ImageMatrix = horzcat(ImageMatrix,Image7Column);
ImageNames = strvcat(ImageNames,Image7Name); %#ok We want to ignore MLint error checking for this line.
end
if strcmp(Image8Name,'/') ~= 1
Image8Column = reshape(Image8,[],1);
ImageMatrix = horzcat(ImageMatrix,Image8Column);
ImageNames = strvcat(ImageNames,Image8Name); %#ok We want to ignore MLint error checking for this line.
end
if strcmp(Image9Name,'/') ~= 1
Image9Column = reshape(Image9,[],1);
ImageMatrix = horzcat(ImageMatrix,Image9Column);
ImageNames = strvcat(ImageNames,Image9Name); %#ok We want to ignore MLint error checking for this line.
end
%%% Applies the mask, if requested
if strcmp(ObjectName,'/') ~= 1
    %%% Turns the image with labeled objects into a binary image in the shape of
    %%% a column.
    MaskLabelMatrixImageColumn = reshape(MaskLabelMatrixImage,[],1);
    MaskBinaryImageColumn = MaskLabelMatrixImageColumn>0;
    %%% Yields the locations of nonzero pixels.
    ObjectLocations = find(MaskBinaryImageColumn);
    if (length(ObjectLocations) == 0),
        %%% If there is no data, return without saving to handles
        return;
    end
    %%% Removes the non-object pixels from the image matrix.
    ObjectImageMatrix = ImageMatrix(ObjectLocations,:);
    %%% Calculates the correlation coefficient.
    Results = corrcoef(ObjectImageMatrix);
else
    %%% Calculates the correlation coefficient.
    Results = corrcoef(ImageMatrix);
end

%%%%%%%%%%%%%%%%%%%%%%
%%% DISPLAY RESULTS %%%
%%%%%%%%%%%%%%%%%%%%%%
drawnow

% PROGRAMMING NOTE
% DISPLAYING RESULTS:
% Each module checks whether its figure is open before calculating
% images that are for display only. This is done by examining all the
% figure handles for one whose handle is equal to the assigned figure
% number for this algorithm. If the figure is not open, everything
% between the "if" and "end" is ignored (to speed execution), so do
% not do any important calculations here. Otherwise an error message
% will be produced if the user has closed the window but you have
% attempted to access data that was supposed to be produced by this
% part of the code. If you plan to save images which are normally
% produced for display only, the corresponding lines should be moved
% outside this if statement.

fieldname = ['figurealgorithm',CurrentAlgorithm];
ThisAlgFigureNumber = handles.(fieldname);
if any(findobj == ThisAlgFigureNumber) == 1;
% PROGRAMMING NOTE
% DRAWNOW BEFORE FIGURE COMMAND:
% The "drawnow" function executes any pending figure window-related
% commands.  In general, Matlab does not update figure windows until
% breaks between image analysis modules, or when a few select commands
% are used. "figure" and "drawnow" are two of the commands that allow
% Matlab to pause and carry out any pending figure window- related
% commands (like zooming, or pressing timer pause or cancel buttons or
% pressing a help button.)  If the drawnow command is not used
% immediately prior to the figure(ThisAlgFigureNumber) line, then
% immediately after the figure line executes, the other commands that
% have been waiting are executed in the other windows.  Then, when
% Matlab returns to this module and goes to the subplot line, the
% figure which is active is not necessarily the correct one. This
% results in strange things like the subplots appearing in the timer
% window or in the wrong figure window, or in help dialog boxes.
    drawnow
    if handles.setbeinganalyzed == 1;
        %%% Sets the width of the figure window to be appropriate (half width).
        originalsize = get(ThisAlgFigureNumber, 'position');
        newsize = originalsize;
        newsize(3) = 350;
        set(ThisAlgFigureNumber, 'position', newsize);
    end
    %%% Activates the appropriate figure window.
    figure(ThisAlgFigureNumber);
    %%% Displays the results.
    Displaytexthandle = uicontrol(ThisAlgFigureNumber,'style','text', 'position', [0 0 335 400],'fontname','fixedwidth','backgroundcolor',[0.7,0.7,0.7]);
    TextToDisplay = ['Image Set # ',num2str(handles.setbeinganalyzed)];
    for i = 1:size(ImageNames,1)-1
        for j = i+1:size(ImageNames,1)
            Value = num2str(Results(i,j));
            TextToDisplay = strvcat(TextToDisplay, [ImageNames(i,:),'/', ImageNames(j,:),' Correlation: ',Value]); %#ok We want to ignore MLint error checking for this line.
        end
    end
    set(Displaytexthandle,'string',TextToDisplay)
    set(ThisAlgFigureNumber,'toolbar','figure')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SAVE DATA TO HANDLES STRUCTURE %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
drawnow

% PROGRAMMING NOTE
% HANDLES STRUCTURE:
%       In CellProfiler (and Matlab in general), each independent
% function (module) has its own workspace and is not able to 'see'
% variables produced by other modules. For data or images to be shared
% from one module to the next, they must be saved to what is called
% the 'handles structure'. This is a variable, whose class is
% 'structure', and whose name is handles. Data which should be saved
% to the handles structure within each module includes: any images,
% data or measurements which are to be eventually saved to the hard
% drive (either in an output file, or using the SaveImages module) or
% which are to be used by a later module in the analysis pipeline. Any
% module which produces or passes on an image needs to also pass along
% the original filename of the image, named after the new image name,
% so that if the SaveImages module attempts to save the resulting
% image, it can be named by appending text to the original file name.
% handles.Pipeline is for storing data which must be retrieved by other modules.
% This data can be overwritten as each image set is processed, or it
% can be generated once and then retrieved during every subsequent image
% set's processing, or it can be saved for each image set by
% saving it according to which image set is being analyzed.
%       Anything stored in handles.Measurements or handles.Pipeline
% will be deleted at the end of the analysis run, whereas anything
% stored in handles.Settings will be retained from one analysis to the
% next. It is important to think about which of these data should be
% deleted at the end of an analysis run because of the way Matlab
% saves variables: For example, a user might process 12 image sets of
% nuclei which results in a set of 12 measurements ("TotalNucArea")
% stored in the handles structure. In addition, a processed image of
% nuclei from the last image set is left in the handles structure
% ("SegmNucImg"). Now, if the user uses a different algorithm which
% happens to have the same measurement output name "TotalNucArea" to
% analyze 4 image sets, the 4 measurements will overwrite the first 4
% measurements of the previous analysis, but the remaining 8
% measurements will still be present. So, the user will end up with 12
% measurements from the 4 sets. Another potential problem is that if,
% in the second analysis run, the user runs only an algorithm which
% depends on the output "SegmNucImg" but does not run an algorithm
% that produces an image by that name, the algorithm will run just
% fine: it will just repeatedly use the processed image of nuclei
% leftover from the last image set, which was left in the handles
% structure ("SegmNucImg").
%       Note that two types of measurements are typically made: Object
% and Image measurements.  Object measurements have one number for
% every object in the image (e.g. ObjectArea) and image measurements
% have one number for the entire image, which could come from one
% measurement from the entire image (e.g. ImageTotalIntensity), or
% which could be an aggregate measurement based on individual object
% measurements (e.g. ImageMeanArea).  Use the appropriate prefix to
% ensure that your data will be extracted properly.
%       Saving measurements: The data extraction functions of
% CellProfiler are designed to deal with only one "column" of data per
% named measurement field. So, for example, instead of creating a
% field of XY locations stored in pairs, they should be split into a field
% of X locations and a field of Y locations. Measurements must be
% stored in double format, because the extraction part of the program
% is designed to deal with that type of array only, not cell or
% structure arrays. It is wise to include the user's input for
% 'ObjectName' as part of the fieldname in the handles structure so
% that multiple modules can be run and their data will not overwrite
% each other.
%       Extracting measurements: handles.Measurements.CenterXNuclei{1}(2) gives
% the X position for the second object in the first image.
% handles.Measurements.AreaNuclei{2}(1) gives the area of the first object in
% the second image.

if strcmp(ObjectName,'/') == 1
ObjectName = 'overall';
else ObjectName = ['within',ObjectName];
end

%%% Warning: this module will exit before reaching this point if there
%%% are no objects defined in the mask when it is requested.  See
%%% above.

for i = 1:size(ImageNames,1)-1
    for j = i+1:size(ImageNames,1)
        Value = Results(i,j);
        HeadingName = [char(cellstr(ImageNames(i,:))), char(cellstr(ImageNames(j,:)))];
        fieldname = ['ImageCorrelation', HeadingName, ObjectName];
        handles.Measurements.(fieldname)(handles.setbeinganalyzed) = {Value};
    end
end
