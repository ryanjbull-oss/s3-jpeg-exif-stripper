def strip_exif_metadata(image_file):
    from PIL import Image
    from io import BytesIO

    # Open the image file
    with Image.open(image_file) as img:
        # Create a new image without EXIF data
        img_no_exif = Image.new(img.mode, img.size)
        img_no_exif.putdata(list(img.getdata()))

        # Save the cleaned image to a BytesIO object
        output = BytesIO()
        img_no_exif.save(output, format='JPEG')
        output.seek(0)

    return output.getvalue()