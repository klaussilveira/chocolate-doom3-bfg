# Chocolate DOOM-3-BFG

Chocolate DOOM-3-BFG is a source port of Doom 3: BFG Edition, forked from the excellent [RBDOOM-3-BFG](https://github.com/RobertBeckebans/RBDOOM-3-BFG) project by Robert Beckebans. Unlike other modern ports that add new features and graphical enhancements, our primary goal is to accurately reproduce the experience of playing Vanilla Doom 3 BFG, while leveraging the modernized BFG engine's compatibility and performance improvements.

While RBDOOM-3-BFG is an impressive project that has introduced many amazing new features such as shadow mapping, Physically Based Rendering, Image Based Lighting, and more, efforts which should be genuinely commended, Chocolate DOOM-3-BFG deliberately takes the opposite approach.

Chocolate DOOM-3-BFG was forked from RBDOOM-3-BFG at a specific point in its development history: right before the introduction of shadow mapping. This was a deliberate choice to maintain the authentic visual experience of the original Doom 3 while still benefiting from the underlying engine improvements of the BFG edition.

We have backported bug fixes and features from [RBDOOM-3-BFG](https://github.com/RobertBeckebans/RBDOOM-3-BFG) and [CstDoom3-BFG](https://www.moddb.com/mods/cstdoom3-bfg) that align with the project's philosophy. The project maintains a careful balance between fixing technical issues and preserving the original gameplay and visual experience.

![Image](https://github.com/user-attachments/assets/593001d4-5b76-439c-b65a-e02689798195)

## Project Goals

- **Authenticity**: Accurately reproduce the experience of playing Vanilla Doom 3 on the modernized BFG engine
- **Bug Fixes**: Correct gameplay bugs introduced in the BFG edition
- **Compatibility**: Ensure the game works on as many platforms as possible
- **Accessibility**: Reduce minimum system requirements to make the game playable on more hardware
- **Performance**: Focus on optimizing performance while maintaining the original visual aesthetic
- **Preservation**: Serve as a reference implementation for any future source ports

This project has backported bug fixes and features that match its preservation mindset from RBDOOM-3-BFG and CstDoom3-BFG. All contributions that align with the project rationale are welcome.

## Build

    $ mkdir build
    $ cd build
    $ cmake ..
    $ make

## Running

You will need the original game data files (`base/` directory, etc.) from a legitimate copy of **Doom 3: BFG Edition** to run Chocolate DOOM-3-BFG. Place the executable in the same directory as your `Doom 3 BFG Edition` folder or configure the path accordingly.

## Contributions

Contributions are welcome, especially those that:

- Fix bugs present in BFG Edition
- Improve performance without changing the vanilla experience
- Enhance compatibility with different platforms
- Maintain the original Doom 3 gameplay and aesthetics

## License

ChocolateDOOM3-BFG is released under the **GNU General Public License version 3** (GPLv3), the same license as RBDOOM-3-BFG and the original Doom 3 source code release. See the `COPYING.txt` file for details.

## Acknowledgements
* **id Software** for creating Doom 3 and releasing the source code.
* **Robert Beckebans**, for his incredible work modernizing the engine, which forms the foundation of this project.
* **Stephen Saunders**, for his contributions and fixes and amazing expertise.
* **Daniel Gibson**, for dhewm3 and all his contributions to the Doom 3 community.
* The rest of the **RBDOOM-3-BFG team** for their incredible work modernizing the engine, which forms the foundation of this project.
* The **CstDoom3-BFG team** for their contributions and fixes.
