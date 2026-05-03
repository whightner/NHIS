"""
app/utils/file_handler.py
--------------------------
Utility for saving uploaded patient photos to the storage directory.
"""

import logging
import os

from fastapi import UploadFile

from app.core.constants import StoragePaths

logger = logging.getLogger(__name__)


def save_photo(file: UploadFile, uhid: str) -> str:
    """
    Save an uploaded photo to the standard photos storage directory.

    The file is named ``{uhid}{extension}`` to ensure one canonical
    photo per patient (overwriting any previous upload).

    :param file: The uploaded :class:`UploadFile` from FastAPI.
    :param uhid: Patient UHID used as the base filename.
    :return: Relative path to the saved file.
    :raises OSError: If the directory cannot be created or the file
                     cannot be written.
    """
    os.makedirs(StoragePaths.PHOTOS, exist_ok=True)

    ext = os.path.splitext(file.filename or "")[-1].lower() or ".jpg"
    filename = f"{uhid}{ext}"
    file_path = os.path.join(StoragePaths.PHOTOS, filename)

    with open(file_path, "wb") as dest:
        content = file.file.read()
        dest.write(content)

    logger.debug("Photo saved: %s (%d bytes)", file_path, len(content))
    return file_path
