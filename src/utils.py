import piexif
from io import BytesIO

def strip_exif_metadata(image_bytes):
    # Load EXIF from input bytes
    exif_dict = piexif.load(image_bytes)

    # Clear all EXIF tags
    for ifd in exif_dict:
        exif_dict[ifd] = {} if ifd != "thumbnail" else None

    # Prepare output buffer
    output_io = BytesIO()

    # Insert cleaned EXIF into output buffer
    piexif.insert(piexif.dump(exif_dict), image_bytes, output_io)

    # Reset pointer and return bytes
    output_io.seek(0)
    return output_io.getvalue()
