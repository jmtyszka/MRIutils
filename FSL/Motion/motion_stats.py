#!/usr/bin/env python3
"""
Extract motion stats from a FSL FEAT or ICA directory

Usage
----
motion_stats.py -i <FEAT directory>
motion_stats.py -h

Authors
----
Mike Tyszka, Caltech, Division of Humaninities and Social Sciences

Dates
----
2016-05-22 JMT Adapt from old Matlab code

License
----
This file is part of MRIutils.

    MRIutils is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    MRIutils is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with MRIutils.  If not, see <http://www.gnu.org/licenses/>.

Copyright
----
2016 California Institute of Technology.
"""

__version__ = '0.1.0'

import os
import sys
import argparse
import numpy as np


def main():

    # Parse command line arguments
    parser = argparse.ArgumentParser(description='Summarize motion stats from preprocessed FEAT directory')
    parser.add_argument('-i', '--featdir', help="FEAT directory name")

    # Parse command line arguments
    args = parser.parse_args()
    featdir = args.featdir

    # Open motion correction parameter file within FEAT directory
    # Should be in <featdir>/mc/prefiltered_func_data_mcf.par
    mcf_file = os.path.join(featdir, 'mc', 'prefiltered_func_data_mcf.par')

    # Check for existance
    if not os.path.isfile(mcf_file):
        print('*** Motion parameter file does not exist (%s)' % mcf_file)
        sys.exit(1)

    # Read file into 2D array
    try:
        M = np.loadtxt(mcf_file)
    except:
        print('*** Could not load motion data from file')
        sys.exit(1)

    print(M.shape)


def total_rotation(theta_x, theta_y, theta_z):
    """
    Total rotation for a three-axis gimble rotation
    Adapted from the discussion thread at http://www.mathworks.com/matlabcentral/newsreader/view_thread/160945
    """

    # Find length of angle vectors
    n = theta_x.shape[0]

    # Make space for results
    theta_total = np.zeros([n,1])
    axis_total  = np.zeros([n,3])

    for i, tx in enumerate(theta_x):

        # Construct total rotation matrix
        ctx = np.cos(tx)
        stx = np.sin(tx)
        Rx = np.array([[1,0,0], [0,ctx,-stx], [0,stx,ctx]])

        cty = np.cos(theta_y[i])
        sty = np.sin(theta_y[i])
        Ry = np.array([[cty,0,sty], [0,1,0] ,[-sty,0,cty]])

        ctz = np.cos(theta_z[i])
        stz = np.sin(theta_z[i])
        Rz = np.array([[ctz,-stz,0], [stz,ctz,0], [0,0,1]])

        # Total rotation matrix is product of axis rotations
        Rtot = np.dot(Rz, np.dot(Ry,Rx))

        # Direct calculation of angle and axis from A
        # Code adapted from thread response by Bruno Luong

        # Rotation axis u = [x, y, z]
        u = np.array([Rtot[2,1]-Rtot[1,2], Rtot[0,2]-Rtot[2,0], Rtot[1,0]-Rtot[0,1]])

        # Rotation sine and cosine
        c = np.trace(Rtot) - 1
        s = np.linalg.norm(u)

        # Better than using acos or asin
        theta_total[i] = np.arctan2(s,c)

        # Adjust rotation to be positive, flipping axis if necessary
        if s > 0:
            u /= s
        else:
            # warning('A close to identity, arbitrary result');
            u = [1, 0, 0]

        # Save axis result
        axis_total[i,:] = u


# This is the standard boilerplate that calls the main() function.
if __name__ == '__main__':
    main()