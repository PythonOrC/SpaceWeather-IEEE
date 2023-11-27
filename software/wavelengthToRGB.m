% This function converts a given wavelength of light to an
% approximate RGB color value. The wavelength must be given
% in nanometers in the range from 380 nm through 750 nm
%
% input: wavelength - wavelength in nm
% output: RGB - color in RGB format
%
function RGB = wavelengthToRGB(wavelength)
        gamma = 0.80;

    if wavelength >= 380 && wavelength < 440
        attenuation = 0.3 + 0.7 * (wavelength - 380) / (440 - 380);
        r = ((-(wavelength - 440) / (440 - 380)) * attenuation) ^ gamma;
        g = 0.0;
        b = (1.0 * attenuation) ^ gamma;
    elseif wavelength >= 440 && wavelength < 490
        r = 0.0;
        g = ((wavelength - 440) / (490 - 440)) ^ gamma;
        b = 1.0;
    elseif wavelength >= 490 && wavelength < 510
        r = 0.0;
        g = 1.0;
        b = (-(wavelength - 510) / (510 - 490)) ^ gamma;
    elseif wavelength >= 510 && wavelength < 580
        r = ((wavelength - 510) / (580 - 510)) ^ gamma;
        g = 1.0;
        b = 0.0;
    elseif wavelength >= 580 && wavelength < 645
        r = 1.0;
        g = (-(wavelength - 645) / (645 - 580)) ^ gamma;
        b = 0.0;
    elseif wavelength >= 645 && wavelength < 781
        attenuation = 0.3 + 0.7 * (780 - wavelength) / (780 - 645);
        r = (1.0 * attenuation) ^ gamma;
        g = 0.0;
        b = 0.0;
    else
        r = 0.0;
        g = 0.0;
        b = 0.0;
    end

    RGB = [r, g, b];
end