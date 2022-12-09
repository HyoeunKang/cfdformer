# CFDformer
## _CFDformer: Novel Fluid Flow Approximation based on ViT and U-Net_

A project concerned with the prediction of velocity field using ViT and U-Net architectures. If you exploit this work for your own research, please consider citing the article or the pre-print. This work was produced during the PhD thesis of [Hyoeun Kang](https://github.com/HyoeunKang).

## Features
- We use CFDTool to generate a dataset
- We fixed the inlet and outlet in a 2D space with Width=200, Height=300
- We set the boundary condition elements {0: inner of an obstacle, 1: cell, 2: non-slip wall, 3: inlet, 4: outlet,  5: wall of an obstacle}
- We collect data while changing two velocity components 

## Needs
- [MATLAB](https://kr.mathworks.com/products/matlab.html)
- [MATLAB CFDTool](https://github.com/precise-simulation/cfdtool)
- [Python3](https://www.python.org/downloads/)
