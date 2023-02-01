/*
Copyright © 2023 Miriady, catwalk authors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

package version

import (
	"bytes"
	"runtime/debug"
	"text/template"

	"github.com/blang/semver/v4"
)

var (
	Name    string = "unknown"
	Version string = "0.0.0"
)

type CompileInfo struct {
	Package    string         `json:"package"`
	Version    semver.Version `json:"version"`
	GoVersion  string         `json:"go_version"`
	Commit     string         `json:"commit_sha"`
	CommitTime string         `json:"commit_time"`
	Modified   bool           `json:"modified"`
}

var stringTemplate = `{{ .Package }}:
  Version: {{ .Version }}
  Commit: {{ .Commit }}
  CommitTime: {{ .CommitTime }}
  Modified: {{ .Modified }}
  GoVersion: {{ .GoVersion }}`

func (ci CompileInfo) String() string {
	tpl := template.New("CompileInfo")
	tpl, err := tpl.Parse(stringTemplate)
	if err != nil {
		panic(err)
	}

	buf := new(bytes.Buffer)
	if err := tpl.Execute(buf, ci); err != nil {
		panic(err)
	}

	return buf.String()
}

func Get() CompileInfo {
	out := CompileInfo{
		Package: Name,
		Version: semver.MustParse(Version),
	}

	z, ok := debug.ReadBuildInfo()
	if !ok {
		return out
	}

	out.GoVersion = z.GoVersion
	for _, s := range z.Settings {
		switch s.Key {
		case "vcs.revision":
			out.Commit = s.Value
		case "vcs.time":
			out.CommitTime = s.Value
		case "vcs.modified":
			out.Modified = s.Value == "true"
		}
	}

	return out
}
