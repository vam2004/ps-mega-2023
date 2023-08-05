# Files
- Detailed installation process is described in `schema.md`
- Table specs also should be described in `schema.md`
- Database operations should be put in `database` directory
- The compilation process may be done with `run.sh` (please read it before using)
# Branch
- `main`: stable version, fast-foward from `devel`
- `devel`: unstable version, commits fowarded from `nightly` as soon as possible
- `nightly`: commits dones at end of day, fowarded to `devel` after conflict resolution
# Testing
You can type the following command to start the containers:

    docker compose up -d

Then you can enter in the main container by typing the following command on **posix** systems:

    ./enter.sh
    
In **windows**, you can type:

    .\enter.bat

In the main container, you can finnally type the following command to compile and run:

    ./run.sh
    

