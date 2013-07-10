%  Perform a subset of NIFTI sform/qform transform. Transforms like
%  (Translation, Flipping, and a few Rotation (N*90 degree) are 
%  supported. Other transforms (any degree rotation, shears, etc.)
%  are not supported, because in those transforms, each voxel has 
%  to be repositioned, interpolated, and whole image(s) will have 
%  to be reconstructed. If an input data (nii) can not be handled,
%  The program will exit with an error message "Transform of this 
%  NIFTI data is not supported by the program". After the transform,
%  nii will be in RAS orientation, i.e. X axis from Left to Right,
%  Y axis from Posterior to Anterior, and Z axis from Inferior to
%  Superior. The RAS orientation system sometimes is also referred
%  as right-hand coordinate system, or Neurologist preferred system.
%
%  NOTE: This function should be called immediately after load_nii,
%        if loaded data will be sent to view_nii, plsgui, etc.
%  
%  Usage: [ nii ] = xform_nii(nii)
%  
%  nii	- NIFTI structure (returned from load_nii)
%  
%  NIFTI data format can be found on: http://nifti.nimh.nih.gov
%  
%  7-nov-2005: Images whose cardinal planes are slightly off Cartesian
%	coordinates will also be loaded. However, this approximation
%	is based on the following assumption: In affine matrix, any
%	value (absolute) below a tenth of the third largest value
%	(absolute) can be ignored and replaced with 0. In this case,
%	fields 'old_affine' & 'new_affine' will be added into hdr.hist.
%	If you can not accept the above assumption, simply discard any
%	nii structure with fields 'old_affine' & 'new_affine'.
%
%  - Jimmy Shen (pls@rotman-baycrest.on.ca)
%
function nii = xform_nii(nii)

   %  There is no need for this program to transform Analyze data
   %
   if nii.filetype == 0
      return;			% no sform/qform for Analyze format
   end

   hdr = nii.hdr;

   %  if scl_slope field is nonzero, then each voxel value in the
   %  dataset should be scaled as: y = scl_slope * x + scl_inter
   %  I bring it here because hdr will be modified by change_hdr.
   %
   scl_slope = hdr.dime.scl_slope;

   [hdr orient] = change_hdr(hdr);

   %  flip and/or rotate image data
   %
   if ~isequal(orient, [1 2 3])

      old_dim = hdr.dime.dim([2:4]);

      %  More than 1 time frame
      %
      if ndims(nii.img) > 3
         pattern = 1:prod(old_dim);
      else
         pattern = [];
      end

      if ~isempty(pattern)
         pattern = reshape(pattern, old_dim);
      end

      %  calculate for rotation after flip
      %
      rot_orient = mod(orient + 2, 3) + 1;

      %  do flip:
      %
      flip_orient = orient - rot_orient;

      for i = 1:3
         if flip_orient(i)
            if ~isempty(pattern)
               pattern = flipdim(pattern, i);
            else
               nii.img = flipdim(nii.img, i);
            end
         end
      end

      %  get index of orient (rotate inversely)
      %
      [tmp rot_orient] = sort(rot_orient);

      new_dim = old_dim;
      new_dim = new_dim(rot_orient);
      hdr.dime.dim([2:4]) = new_dim;

      %  re-calculate originator
      %
      tmp = hdr.hist.originator([1:3]);
      tmp = tmp(rot_orient);
      flip_orient = flip_orient(rot_orient);

      for i = 1:3
         if flip_orient(i) & ~isequal(tmp(i), 0)
            tmp(i) = new_dim(i) - tmp(i) + 1;
         end
      end

      hdr.hist.originator([1:3]) = tmp;

      %  do rotation:
      %
      if ~isempty(pattern)
         pattern = permute(pattern, rot_orient);
         pattern = pattern(:);

         nii.img = reshape(nii.img, [prod(new_dim) hdr.dime.dim(5)]);
         nii.img = nii.img(pattern, :);
         nii.img = reshape(nii.img, [new_dim       hdr.dime.dim(5)]);
      else
         nii.img = permute(nii.img, rot_orient);
      end
   end

   nii.hdr = hdr;

   if scl_slope ~= 0 & ...
	ismember(nii.hdr.dime.datatype, [2,4,8,16,64,256,512,768])

      nii.img = scl_slope * double(nii.img) + hdr.dime.scl_inter;

      switch nii.hdr.dime.datatype
      case   2,
         nii.img = uint8(nii.img);
      case   4,
         nii.img = int16(nii.img);
      case   8,
         nii.img = int32(nii.img);
      case  16,
         nii.img = single(nii.img);
      case  64,
         nii.img = double(nii.img);
      case 256 
         nii.img = int8(nii.img);
      case 512 
         nii.img = uint16(nii.img);
      case 768 
         nii.img = uint32(nii.img);
      end
   end

   return;					% xform_nii


%-----------------------------------------------------------------------
function [hdr, orient] = change_hdr(hdr)

   orient = [1 2 3];
   affine_transform = 1;

   %  NIFTI can have both sform and qform transform. This program
   %  will check sform_code prior to qform_code
   %
   if hdr.hist.sform_code > 0
	   R = [hdr.hist.srow_x(1:3)
		hdr.hist.srow_y(1:3)
		hdr.hist.srow_z(1:3)];

	   T = [hdr.hist.srow_x(4)
		hdr.hist.srow_y(4)
		hdr.hist.srow_z(4)];
   elseif hdr.hist.qform_code > 0
	   b = hdr.hist.quatern_b;
	   c = hdr.hist.quatern_c;
	   d = hdr.hist.quatern_d;
	   a = sqrt(1.0-(b*b+c*c+d*d));

	   qfac = hdr.dime.pixdim(1);
	   i = hdr.dime.pixdim(2);
	   j = hdr.dime.pixdim(3);
	   k = qfac * hdr.dime.pixdim(4);

	   R = [a*a+b*b-c*c-d*d     2*b*c-2*a*d        2*b*d+2*a*c
		2*b*c+2*a*d         a*a+c*c-b*b-d*d    2*c*d-2*a*b
	        2*b*d-2*a*c         2*c*d+2*a*b        a*a+d*d-c*c-b*b];

	   R = R * diag([i j k]);

	   T = [hdr.hist.qoffset_x
		hdr.hist.qoffset_y
		hdr.hist.qoffset_z];
   else
      affine_transform = 0;	% no sform or qform transform
   end

   if affine_transform == 1
      if det(R) == 0 | ~isequal(R(find(R)), sum(R)')
         hdr.hist.old_affine = R;
         R_sort = sort(abs(R(:)));
         R( find( abs(R) < min(R_sort(end-2:end))/10 ) ) = 0;
         hdr.hist.new_affine = R;

         if det(R) == 0 | ~isequal(R(find(R)), sum(R)')
            error('Transform of this NIFTI data is not supported by the program.');
         end
      end

      voxel_size = abs(sum(R,1));
      originator = abs(1-T./sum(R,2))';
      orient = get_orient(R);

      %  modify pixdim and originator
      %
      hdr.dime.pixdim(2:4) = voxel_size;
      hdr.hist.originator(1:3) = originator;

      %  set sform or qform to non-use, because they have been
      %  applied in xform_nii
      %
      hdr.hist.qform_code = 0;
      hdr.hist.sform_code = 0;
   end

   %  apply space_unit to pixdim if not 1 (mm)
   %
   space_unit = get_units(hdr);

   if space_unit ~= 1
      hdr.dime.pixdim(2:4) = hdr.dime.pixdim(2:4) * space_unit;

      %  set space_unit of xyzt_units to millimeter, because
      %  voxel_size has been re-scaled
      %
      hdr.dime.xyzt_units = char(bitset(hdr.dime.xyzt_units,1,0));
      hdr.dime.xyzt_units = char(bitset(hdr.dime.xyzt_units,2,1));
      hdr.dime.xyzt_units = char(bitset(hdr.dime.xyzt_units,3,0));
   end

   %  set scale to non-use, because it is applied in xform_nii
   %
   if hdr.dime.scl_slope ~= 0
      hdr.dime.scl_slope = 0;
   end

   return;					% change_hdr


%-----------------------------------------------------------------------
function orient = get_orient(R)

   orient = [];

   for i = 1:3
      switch find(R(i,:)) * sign(sum(R(i,:)))
      case 1
         orient = [orient 1];		% Left to Right
      case 2
         orient = [orient 2];		% Posterior to Anterior
      case 3
         orient = [orient 3];		% Inferior to Superior
      case -1
         orient = [orient 4];		% Right to Left
      case -2
         orient = [orient 5];		% Anterior to Posterior
      case -3
         orient = [orient 6];		% Superior to Inferior
      end
   end

   return;					% get_orient


%-----------------------------------------------------------------------
function [space_unit, time_unit] = get_units(hdr)

   switch bitand(hdr.dime.xyzt_units, 7)	% mask with 0x07
   case 1
      space_unit = 1e+3;		% meter, m
   case 3
      space_unit = 1e-3;		% micrometer, um
   otherwise
      space_unit = 1;			% millimeter, mm
   end

   switch bitand(hdr.dime.xyzt_units, 56)	% mask with 0x38
   case 16
      time_unit = 1e-3;			% millisecond, ms
   case 24
      time_unit = 1e-6;			% microsecond, us
   otherwise
      time_unit = 1;			% second, s
   end

   return;					% get_units

