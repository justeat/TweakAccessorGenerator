# TweakAccessorGenerator

This tool generates Swift code for accessing flags using JustTweak.

The tool should be invoked with the following arguments:

```
--local-tweaks-file-path <path_to_the_tweaks_file>
--output-folder <path_to_the_output_folder>
--configuration-path <path_to_the_configuration_json_file>
```

The configuration json file should contain the following:

```json
{
    "accessorName": "GeneratedTweakAccessor"
}
```
