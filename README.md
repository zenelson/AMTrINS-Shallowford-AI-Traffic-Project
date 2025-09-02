<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a id="readme-top"></a>
<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Don't forget to give the project a star!
*** Thanks again! Now go create something AMAZING! :D
-->



<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->





<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

##[![Product Name Screen Shot][product-screenshot]](https://example.com)

This was a dissertation project to design a novel and decentralized intersection based on a modular form or reinforcement learning with Dyna-Q capabilities. The goal was to create a machine learning AI that could manage traffic in a way that could not only be explainable but also decentralized and scale upwards through scalable negotiations with neighboring intersections.

The program utilizes a hybrid application of MATLAB, SUMO(Simulation of Urban Mobility), and a handshake program where MATLAB will handle the AI aspects, SUMO generates the traffic environment, and the handshake program allows MATLAB to influence and observe the SUMO simulation.

The document here is partly for the benefit of Dr. Subhadeep Chakraborty and the CoSMoS lab located at the University of Tennessee - Knoxville. This is to allow all future faculty to have access to a copy of the program available if needed.

While the main program and all relevant functions will be provided, the raw historical data that was provided for the research is withheld due to legal and copyright reasons with the organizations that created the original data. The converted data in XML files for SUMO to emulate, however, will be provided.

The program also utilizes Dyna-Q Reinforcement Learning as a means to build probability models of likely transitions and to boost the convergence rate of the program.

The repository should include the following:
* MATLAB scripts that manage all AI/ML functions and model-generation
* SUMO files that include the creation of the environment, intersection logic, and reproducible vehicle routing data.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



### Built With

This section should list any major frameworks/libraries used to bootstrap your project. Leave any add-ons/plugins for the acknowledgements section. Here are a few examples.

* [![MATLAB][MATLAB.com]][MATLAB-url]
* [![SUMO][SUMO.com][SUMO-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- GETTING STARTED -->
## Getting Started

This is an example of how you may give instructions on setting up your project locally.
To get a local copy up and running follow these simple example steps.

### Prerequisites

In order for SUMO to operate with MATLAB, a modified version of TrACI is utilized. 

1. Open Windows Explorer and right click on "My Computer/This PC"
2. Select "Properties"
3. Select "Advanced System Settings"
4. Select "Advanced Tab"
5. Select "Environment Variables"
6. Select the Variable "Path" in the "System Variables" list
	a. Select "Edit"
7. Select Browse to select the "bin" folder located in the SUMO program
	a. Ex: OS (C:)\Program Files(x86)\Eclipse\Sumo\bin
8. Search the Sumo files for the "TraCI4Matlab" folder
	a. Should be located at "Sumo\tools\contributed"
	b. Be sure to search and confirm that the folder "traci4matlab" contains the file 	"traci4matlab.jar"
9. Write a .txt document titled "javaclasspath.txt"
	a. Content of .txt document should be a pathway leading to the "traci4matlab.jar" file
	b. Ex: OS (C:)\Program Files(x86)\Eclipse\Sumo\tools\contributed\traci4matlab\traci4matlab.jar
	c. A copy should be included in this repo
10. Save "javaclasspath.txt" in the preference directory for MATLAB
	a. This can be found by typing "prefdir" in the MATLAB Command Window
11. In MATLAB, type in "pathtool" in the MATLAB command window and select "Add Folder..." in the new window
	a. Browse for the Sumo program files and select the "traci4matlab" folder
	b. Select "Save"

### Installation

_Below is an example of how you can instruct your audience on installing and setting up your app. This template doesn't rely on any external dependencies or services._

1. Clone the repo
   ```sh
   git clone https://github.com/zenelson/AMTrINS-Shallowford-AI-Traffic-Project.git
   ```
2. Change git remote url to avoid accidental pushes to base project
   ```sh
   git remote set-url origin zenelson/AMTrINS-Shallowford-AI-Traffic-Project.git
   git remote -v # confirm the changes
   ```



<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- USAGE EXAMPLES -->
## Usage

This program is to generate simulations of traffic flows moving towards a traffic intersection. The intersection is governed by a custom-built reinforcement learning program with Dyna-Q and a rudimentary queue prediction program to update and assist providing predictions for Dyna-Q's model generation.

Additional program may be created in the near future that focus on adding newer upgrades to the current scenario and may be added in their own repositories.


<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ROADMAP -->
## Roadmap

- [x] Add Original Files
- [ ] Clean up Files
- [ ] Add organized customization options
- [ ] Design user interface




<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTRIBUTING -->




<!-- LICENSE -->
## License

See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Zachariah Nelson - zenelson1994@gmail.com

Project Link: [https://github.com/zenelson/AMTrINS-Shallowford-AI-Traffic-Project.git](https://github.com/zenelson/AMTrINS-Shallowford-AI-Traffic-Project.git)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

Use this space to list resources you find helpful and would like to give credit to. I've included a few of my favorites to kick things off!

* [Choose an Open Source License](https://choosealicense.com)
* [GitHub Emoji Cheat Sheet](https://www.webpagefx.com/tools/emoji-cheat-sheet)
* [Malven's Flexbox Cheatsheet](https://flexbox.malven.co/)
* [Malven's Grid Cheatsheet](https://grid.malven.co/)
* [Img Shields](https://shields.io)
* [GitHub Pages](https://pages.github.com)
* [Font Awesome](https://fontawesome.com)
* [React Icons](https://react-icons.github.io/react-icons/search)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/othneildrew/Best-README-Template.svg?style=for-the-badge
[contributors-url]: https://github.com/othneildrew/Best-README-Template/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/othneildrew/Best-README-Template.svg?style=for-the-badge
[forks-url]: https://github.com/othneildrew/Best-README-Template/network/members
[stars-shield]: https://img.shields.io/github/stars/othneildrew/Best-README-Template.svg?style=for-the-badge
[stars-url]: https://github.com/othneildrew/Best-README-Template/stargazers
[issues-shield]: https://img.shields.io/github/issues/othneildrew/Best-README-Template.svg?style=for-the-badge
[issues-url]: https://github.com/othneildrew/Best-README-Template/issues
[license-shield]: https://img.shields.io/github/license/othneildrew/Best-README-Template.svg?style=for-the-badge
[license-url]: https://github.com/othneildrew/Best-README-Template/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/othneildrew
[product-screenshot]: images/screenshot.png
[Next.js]: https://img.shields.io/badge/next.js-000000?style=for-the-badge&logo=nextdotjs&logoColor=white
[Next-url]: https://nextjs.org/
[React.js]: https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB
[React-url]: https://reactjs.org/
[Vue.js]: https://img.shields.io/badge/Vue.js-35495E?style=for-the-badge&logo=vuedotjs&logoColor=4FC08D
[Vue-url]: https://vuejs.org/
[Angular.io]: https://img.shields.io/badge/Angular-DD0031?style=for-the-badge&logo=angular&logoColor=white
[Angular-url]: https://angular.io/
[Svelte.dev]: https://img.shields.io/badge/Svelte-4A4A55?style=for-the-badge&logo=svelte&logoColor=FF3E00
[Svelte-url]: https://svelte.dev/
[Laravel.com]: https://img.shields.io/badge/Laravel-FF2D20?style=for-the-badge&logo=laravel&logoColor=white
[Laravel-url]: https://laravel.com
[Bootstrap.com]: https://img.shields.io/badge/Bootstrap-563D7C?style=for-the-badge&logo=bootstrap&logoColor=white
[Bootstrap-url]: https://getbootstrap.com
[JQuery.com]: https://img.shields.io/badge/jQuery-0769AD?style=for-the-badge&logo=jquery&logoColor=white
[JQuery-url]: https://jquery.com 
[MATLAB-url]: https://www.mathworks.com
[MATLAB.com]: https://img.shields.io/badge/MATLAB-R2025a-orange
[SUMO-url]: https://eclipse.dev/sumo
[SUMO.com]: https://img.shields.io/badge/SUMO-1.24.0-green
