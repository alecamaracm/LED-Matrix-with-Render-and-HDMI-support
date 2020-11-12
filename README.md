
<!-- PROJECT LOGO -->
<br />
<p align="center">
  <h3 align="center">LED Matrix driver with HDMI input and render support</h3>

  <p align="center">
    LED Matrix driver with support rendering/overlay of content on top of an HDMI input
    <br />
    <a href="https://github.com/alecamaracm/LED-Matrix-with-Render-and-HDMI-support"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/alecamaracm/LED-Matrix-with-Render-and-HDMI-support/issues">Report Bug</a>
    ·
    <a href="https://github.com/alecamaracm/LED-Matrix-with-Render-and-HDMI-support/issues">Request Feature</a>
  </p>
</p>



<!-- TABLE OF CONTENTS -->
## Table of Contents

* [About the Project](#about-the-project)
* [Getting Started](#getting-started)
* [Usage](#usage)
* [Roadmap](#roadmap)
* [Contributing](#contributing)
* [License](#license)
* [Contact](#contact)
* [Acknowledgements](#acknowledgements)



<!-- ABOUT THE PROJECT -->
## About The Project

[![Product Name Screen Shot][screenshot1]](https://example.com)

This project is a LED Matrix driver (Currently only 32:1 matrices supported) with support for an HDMI input and basic "GPU like" overlay rendering commands.

The LED matrix is directly driven from the FPGA (Cyclone 4,5 and MAX8 tested) and supports a pixel rate of up to 135Mhz.

The refresh rate directly depends on the number of color bits per pixel and the pixel clock, currently supporting RGB 16bpp at 60Hz with a pixel clock of 24Mhz.

All flash copy/rendering commands can be sent from the PC and go through an ESP32 which acts as a command buffer for the FPGA.

Other features: USB audio decoding/encoding and USB hub. 

See the screenshots below for working examples.

<!-- GETTING STARTED -->
## Getting Started

To get a local copy of the project and follow these steps.

1. Install Quartus (V13.1 or newer)

2. Install the ESP-IDF (Tested on V2, might working in V3 with some small changes)

3. Connect all the hardware as described in the PCB schematics

[![Product Name Screen Shot][screenshot3]](https://example.com)

<!-- USAGE EXAMPLES -->
## Usage

The easiest example that doesn't require adding the HDMI support is to simply connect the board to your computer through USB, run the desktop app, and upload some media files.
The first uploaded picture should be automatically displayed on the matrix.

You can also use the desktop app to render some basic patterns: 

[![Product Name Screen Shot][screenshot2]](https://example.com)

<!-- ROADMAP -->
## Roadmap
This project has been abandoned as of right now but it is in a "usable" state. There is a decent chance that I will come back to it in the near future, but no guarantees are given.

TODO list:
1. Improve matrix performance during low light conditions.
2. Add support for other row formats (1:16, 1:32, ...)
3. Add support for more "GPU" rendering commands.
4. Add support for reading from SD card instead of eMMC flash.
5. Finalize the HDMI input support. (Currently only writing to a frame buffer is possible)

<!-- CONTRIBUTING -->
## Contributing

Feel free to contribute to the project. Any changes you propose will be quickly reviewed but NOT tested.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request



<!-- LICENSE -->
## License

Distributed under the MIT License.



<!-- CONTACT -->
## Contact

Alejandro Cabrerizo - [@alecamaracm](https://twitter.com/alecamaracm) - [alecamar] AT [hotmail.es]

Project Link: [https://github.com/alecamaracm/LED-Matrix-with-Render-and-HDMI-support](https://github.com/alecamaracm/LED-Matrix-with-Render-and-HDMI-support)



<!-- ACKNOWLEDGEMENTS -->
## Acknowledgements

* [To Peter Jamieson, for being an awesome professor and introducing me to the world of digital systems.](https://twitter.com/peterajamieson)
* [To othneildrew for creating this awesome README template.](https://github.com/othneildrew/Best-README-Template)


<!-- MARKDOWN LINKS & IMAGES -->
[screenshot1]: images/MatrixLS.jpeg
[screenshot2]: images/PatternRendering.jpeg
[screenshot3]: images/PCB.jpeg
