function data = mixedcsvread(file, format, nheader, varargin)
%MIXEDCSVREAD Read csv file with mixed text/numeric columns
%
% data = mixedcsvread(file, format, nheader)
% data = mixedcsvread(file, format, nheader, p1, v1, ...)
%
% This function is a wrapper around textscan to read .csv files,
% particularly those generated by Microsoft Excel.  These files usually
% hold mixed text/numeric data (which can't be read by csvread), but with
% type consistent throughout a column (so readtext is overkill).  They also
% often hold extra empty columns/rows due to errant mouse clicks in Excel.
% Currently this does *not* deal with the quoted-strings-with-commas-inside
% possibility.
%
% Input variables:
%
%   file:       file name
%
%   format:     format specifiers for columns.
%
%   nheader:    number of header rows to skip
%
% Output variables:
%
%   data:       ncol x 1 cell array

% Copyright 2013 Kelly Kearney


% Determine if there are any extra columns or rows

if ~exist(file, 'file')
    error('Could not find file');
end

fid = fopen(file, 'rt');
line1 = fgetl(fid);
commapos = regexp(line1, ',');
ncol = length(commapos);

nusercol = length(regexp(format, '%'));
format = [format repmat('%*s', 1, ncol-nusercol)];

frewind(fid);
if length(line1) > 4095
    tmp = textscan(fid, '%s', 'delimiter', '\n', 'bufsize', length(line1)*1.5);
else
    tmp = textscan(fid, '%s', 'delimiter', '\n');
end
tmp = regexprep(tmp{1}, ',', '');
isemp = cellfun('isempty', tmp);
nrow = find(~isemp, 1, 'last');

% Read data

frewind(fid);
data = textscan(fid, format, nrow-nheader, 'headerlines', nheader, 'delimiter', ',');
nread = length(data{1});
if ~(nread == (nrow-nheader))
    error('Only %d rows of %d read with this format; check for column consisitency', nread, nrow);
end


fclose(fid);
