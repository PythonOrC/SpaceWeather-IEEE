import glob
from PIL import Image
import os


def make_gif(frame_folder):
    file_path = os.path.dirname(os.path.realpath(__file__))
    frames = [
        Image.open(image) for image in glob.glob(f"{file_path}/{frame_folder}/*.png")
    ]
    frames[0].save(
        f"{file_path}/{frame_folder}.gif",
        format="GIF",
        append_images=frames[1:],
        save_all=True,
        duration=100,
        loop=0,
    )


if __name__ == "__main__":
    make_gif("animation")
