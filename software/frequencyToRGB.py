Gamma = 0.80
IntensityMax = 255

def wavelength_to_rgb(wavelength):
    if(wavelength>=380 and wavelength <440):
        r = -(wavelength - 440) / (440 - 380)
        g = 0.0
        b = 1.0
    elif(wavelength>=440 and wavelength<490):
        r = 0.0
        g = (wavelength - 440) / (490 - 440)
        b = 1.0
    elif(wavelength>=490 and wavelength<510):
        r = 0.0
        g = 1.0
        b = -(wavelength - 510) / (510 - 490)
    elif(wavelength>=510 and wavelength<580):
        r = (wavelength - 510) / (580 - 510)
        g = 1.0
        b = 0.0
    elif(wavelength>=580 and wavelength<645):
        r = 1.0
        g = -(wavelength - 645) / (645 - 580)
        b = 0.0
    elif(wavelength>=645 and wavelength<781):
        r = 1.0
        g = 0.0
        b = 0.0
    else:
        r = 0.0
        g = 0.0
        b = 0.0
    # Let the intensity fall off near the vision limits
    if(wavelength>=380 and wavelength<420):
        factor = 0.3 + 0.7*(wavelength - 380) / (420 - 380)
    elif(wavelength>=420 and wavelength<701):
        factor = 1.0
    elif(wavelength>=701 and wavelength<781):
        factor = 0.3 + 0.7*(780 - wavelength) / (780 - 700)
    else:
        factor = 0.0
    if(r!=0):
        r = round((r * factor)**Gamma, 3)
    if(g!=0):
        g = round((g * factor)**Gamma, 3)
    if(b!=0):
        b = round((b * factor)**Gamma, 3)
    return [r,g,b]