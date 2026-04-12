import logging

# Create a logger
logger = logging.getLogger(__name__)

# Set the logger level
logger.setLevel(logging.INFO)

# Create a file handler
handler = logging.FileHandler("logger.log")

# Create a formatter and attach it to the handler
formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")
handler.setFormatter(formatter)

# Add the handler to the logger
logger.addHandler(handler)
