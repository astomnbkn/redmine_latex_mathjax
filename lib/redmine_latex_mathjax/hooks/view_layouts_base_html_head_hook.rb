module RedmineLatexMathjax
  module Hooks
    class ViewLayoutsBaseHtmlHeadHook < Redmine::Hook::ViewListener
      def view_layouts_base_html_head(context={})
          return "<script>
MathJax = {
  options: {
    ignoreHtmlClass: 'tex2jax_ignore',
    processHtmlClass: 'tex2jax_process'
  },
  tex: {
    autoload: {
      // key: package name
      // value: single array of macros, or two arrays of maxro names and environment names
      color: [],
      colorv2: ['color'],
      amscd: [[], ['CD']],
      xypic: [[], ['xy']],
    },
    // //packages: {'[+]': ['noerrors', 'amscd', 'xypic']},
    // packages: {'[+]': ['noerrors', 'require', 'autoload', 'ams', 'amscd']},
    // //packages: {'[-]': ['xypic', 'amscd']},
    // packages: {'[-]': ['xypic']},

    // Combination used in production:
    packages: {'[+]': ['noerrors', 'require', 'autoload']},
    packages: {'[-]': ['xypic', 'amscd']},
    inlineMath: [
      ['" + MathJaxEmbedMacro.delimiterStartInline.html_safe + "','" + MathJaxEmbedMacro.delimiterEndInline.html_safe + "'],
      // ['\\\\(', '\\\\)']
    ],
    displayMath: [             // start/end delimiter pairs for display math
      ['" + MathJaxEmbedMacro.delimiterStartBlock.html_safe + "','" + MathJaxEmbedMacro.delimiterEndBlock.html_safe + "'],
      //['\\\\[', '\\\\]']
    ],
  },
  loader: {
    source: {
      '[tex]/xypic': '" + MathJaxEmbedMacro.URLToXYJax + "',
    },
    //paths: {custom: 'https://cdn.jsdelivr.net/gh/sonoisa/XyJax-v3@3.0.1/build/'},
    //dependencies: {
    //  'xyjax': ['[tex]/noerrors']
    //},
    //load: ['[tex]/noerrors', '[tex]/amscd', '[custom]/xypic.js']
    //load: ['[tex]/noerrors', '[custom]/xypic.js']
    //load: ['[tex]/noerrors', '" + MathJaxEmbedMacro.URLToXYJax + "']
    load: ['[tex]/noerrors', '[tex]/require', '[tex]/ams', '[tex]/amscd', '[tex]/xypic']
  },

  startup: {
    //
    //  Mapping of old extension names to new ones
    //
    requireMap: {
      AMSmath: 'ams',
      AMSsymbols: 'ams',
      AMScd: 'amscd',
      HTML: 'html',
      noErrors: 'noerrors',
      noUndefined: 'noundefined'
    },
    ready: function () {
      //
      //  Replace the require command map with a new one that checks for
      //    renamed extensions and converts them to the new names.
      //
      var CommandMap = MathJax._.input.tex.SymbolMap.CommandMap;
      var requireMap = MathJax.config.startup.requireMap;
      var RequireLoad = MathJax._.input.tex.require.RequireConfiguration.RequireLoad;
      var RequireMethods = {
        Require: function (parser, name) {
          var required = parser.GetArgument(name);
          if (required.match(/[^_a-zA-Z0-9]/) || required === '') {
            throw new TexError('BadPackageName', 'Argument for %1 is not a valid package name', name);
          }
          if (requireMap.hasOwnProperty(required)) {
            required = requireMap[required];
          }
          RequireLoad(parser, required);
        }
      };
      new CommandMap('require', {require: 'Require'}, RequireMethods);
      //
      //  Do the usual startup
      //
      //return MathJax.startup.defaultReady();
      console.log('NEW 5: MathJax is loaded, but not yet initialized');
      MathJax.startup.defaultReady();
      console.log('MathJax is initialized, and the initial typeset is queued');
      MathJax.startup.promise.then(() => {
        console.log('MathJax initial typesetting complete');
      });
    }
  }
};

//
// Add a replacement for MathJax.Callback command
//
MathJax.Callback = function (args) {
  if (Array.isArray(args)) {
    if (args.length === 1 && typeof(args[0]) === 'function') {
      return args[0];
    } else if (typeof(args[0]) === 'string' && args[1] instanceof Object &&
              typeof(args[1][args[0]]) === 'function') {
      return Function.bind.apply(args[1][args[0]], args.slice(1));
    } else if (typeof(args[0]) === 'function') {
      return Function.bind.apply(args[0], [window].concat(args.slice(1)));
    } else if (typeof(args[1]) === 'function') {
      return Function.bind.apply(args[1], [args[0]].concat(args.slice(2)));
    }
  } else if (typeof(args) === 'function') {
    return args;
  }
  throw Error(\"Can't make callback from given data\");
};
//
// Add a replacement for MathJax.Hub commands
//
MathJax.Hub = {
  Queue: function () {
    for (var i = 0, m = arguments.length; i < m; i++) {
       var fn = MathJax.Callback(arguments[i]);
       MathJax.startup.promise = MathJax.startup.promise.then(fn);
    }
    return MathJax.startup.promise;
  },
  Typeset: function (elements, callback) {
     var promise = MathJax.typesetPromise(elements);
     if (callback) {
       promise = promise.then(callback);
     }
     return promise;
  },
  Register: {
     MessageHook: function () {console.log('MessageHooks are not supported in version 3')},
     StartupHook: function () {console.log('StartupHooks are not supported in version 3')},
     LoadHook: function () {console.log('LoadHooks are not supported in version 3')}
  },
  Config: function () {console.log('MathJax configurations should be converted for version 3')}
};
//
//  Warn about x-mathjax-config scripts
//
if (document.querySelector(\'script[type=\"text/x-mathjax-config\"]\')) {
  throw Error(\'x-mathjax-config scripts should be converted to MathJax global variable\');
}

</script>\n" +
            javascript_include_tag(MathJaxEmbedMacro.URLToMathJax) + "
<script type=\"text/javascript\">
  // Own submitPreview script with Mathjax trigger. Copy & Paste of public/javascripts/application.js
  function MJsubmitPreview(url, form, target) {
	$.ajax({
  	  url: url,
  	  type: 'post',
  	  data: $('#'+form).serialize(),
  	  success: function(data){
    	$('#'+target).html(data);
    	MathJax.typeset();
  	  }
	});
  }
  // Replace function submitPreview with own version with a Mathjax trigger
  document.addEventListener(\"DOMContentLoaded\", function() {
	a = document.getElementsByTagName(\"a\");
    for( var x=0; x < a.length; x++ ) {
      if ( a[x].onclick ) {
        str = a[x].getAttribute(\"onclick\");
        if (str.indexOf(\"submitPreview\") === 0) {
      	  a[x].setAttribute(\"onclick\", str.replace(\"submitPreview\",\"MJsubmitPreview\"));
          break;
      	};
      };  
	};	
  });
</script>"
      end
    end
  end
end
