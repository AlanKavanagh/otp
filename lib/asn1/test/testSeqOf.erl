%%
%% %CopyrightBegin%
%%
%% Copyright Ericsson AB 1997-2013. All Rights Reserved.
%%
%% The contents of this file are subject to the Erlang Public License,
%% Version 1.1, (the "License"); you may not use this file except in
%% compliance with the License. You should have received a copy of the
%% Erlang Public License along with this software. If not, it can be
%% retrieved online at http://www.erlang.org/.
%%
%% Software distributed under the License is distributed on an "AS IS"
%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
%% the License for the specific language governing rights and limitations
%% under the License.
%%
%% %CopyrightEnd%
%%
%%
-module(testSeqOf).

-export([main/1]).

-include_lib("test_server/include/test_server.hrl").

-record('Seq1',{bool1, int1, seq1 = asn1_DEFAULT}).
-record('Seq2',{seq2 = asn1_DEFAULT, bool2, int2}).
-record('Seq3',{bool3, seq3 = asn1_DEFAULT, int3}).
-record('Seq4',{seq41 = asn1_DEFAULT, seq42 = asn1_DEFAULT, seq43 = asn1_DEFAULT}).
-record('SeqIn',{boolIn, intIn}).
-record('SeqEmp',{seq1}).
-record('Empty',{}).

main(_Rules) ->
    SeqIn3 = [#'SeqIn'{boolIn=true,intIn=25},
	      #'SeqIn'{boolIn=false,intIn=125},
	      #'SeqIn'{boolIn=false,intIn=225}],

    roundtrip('Seq1', #'Seq1'{bool1=true,int1=17},
	      #'Seq1'{bool1=true,int1=17,seq1=[]}),

    roundtrip('Seq1', #'Seq1'{bool1=true,int1 = 17,
			      seq1=[#'SeqIn'{boolIn=true,
					     intIn=25}]}),
    roundtrip('Seq1', #'Seq1'{bool1=true,
			      int1=17,
			      seq1=SeqIn3}),

    roundtrip('Seq2', #'Seq2'{bool2=true,int2=17},
	      #'Seq2'{seq2=[],bool2=true,int2=17}),
    roundtrip('Seq2',#'Seq2'{bool2=true,int2=17,
			     seq2=[#'SeqIn'{boolIn=true,
					    intIn=25}]}),
    roundtrip('Seq2', #'Seq2'{bool2=true,
			      int2=17,
			      seq2=SeqIn3}),

    roundtrip('Seq3', #'Seq3'{bool3=true,int3=17},
	      #'Seq3'{bool3=true,seq3=[],int3=17}),
    roundtrip('Seq3',#'Seq3'{bool3=true,
			     int3=17,
			     seq3=[#'SeqIn'{boolIn=true,
					    intIn=25}]}),
    roundtrip('Seq3', #'Seq3'{bool3=true,int3=17,seq3=SeqIn3}),

    roundtrip('Seq4', #'Seq4'{}, #'Seq4'{seq41=[],seq42=[],seq43=[]}),

    roundtrip('Seq4', #'Seq4'{seq41=[#'SeqIn'{boolIn=true,intIn=25}]},
	      #'Seq4'{seq41=[#'SeqIn'{boolIn=true,intIn=25}],
		      seq42=[],seq43=[]}),

    roundtrip('Seq4', #'Seq4'{seq41=SeqIn3},
	      #'Seq4'{seq41=SeqIn3,seq42=[],seq43=[]}),
    roundtrip('Seq4', #'Seq4'{seq42=[#'SeqIn'{boolIn=true,intIn=25}]},
	      #'Seq4'{seq41=[],seq42=[#'SeqIn'{boolIn=true,intIn=25}],
		      seq43=[]}),
    roundtrip('Seq4', #'Seq4'{seq42=SeqIn3},
	      #'Seq4'{seq41=[],seq42=SeqIn3,seq43=[]}),
    
    roundtrip('Seq4', #'Seq4'{seq43=[#'SeqIn'{boolIn=true,intIn=25}]},
	      #'Seq4'{seq41=[],seq42=[],
		      seq43=[#'SeqIn'{boolIn=true,intIn=25}]}),
    roundtrip('Seq4', #'Seq4'{seq43=SeqIn3},
	      #'Seq4'{seq41=[],seq42=[],
		      seq43=SeqIn3}),
    
    roundtrip('SeqEmp', #'SeqEmp'{seq1=[#'Empty'{}]}),

    %% Test constrained, extensible size.

    SeqIn = #'SeqIn'{boolIn=true,intIn=978654321},
    roundtrip('SeqExt', {'SeqExt',true,[],true,[],789}),
    roundtrip('SeqExt', {'SeqExt',true,lists:duplicate(1, SeqIn),
			 true,lists:duplicate(0, SeqIn),777}),
    roundtrip('SeqExt', {'SeqExt',true,lists:duplicate(1, SeqIn),
			 true,lists:duplicate(1, SeqIn),777}),
    roundtrip('SeqExt', {'SeqExt',true,lists:duplicate(1, SeqIn),
			 true,lists:duplicate(127, SeqIn),777}),
    roundtrip('SeqExt', {'SeqExt',true,lists:duplicate(2, SeqIn),
			 true,lists:duplicate(128, SeqIn),1777}),
    roundtrip('SeqExt', {'SeqExt',true,lists:duplicate(2, SeqIn),
			 true,lists:duplicate(255, SeqIn),7773}),
    roundtrip('SeqExt', {'SeqExt',true,lists:duplicate(2, SeqIn),
			 true,lists:duplicate(256, SeqIn),77755}),
    roundtrip('SeqExt', {'SeqExt',true,lists:duplicate(2, SeqIn),
			 true,lists:duplicate(257, SeqIn),8888}),
    roundtrip('SeqExt', {'SeqExt',true,lists:duplicate(3, SeqIn),
			 true,lists:duplicate(1024, SeqIn),999988888}),
    roundtrip('SeqExt', {'SeqExt',true,lists:duplicate(15, SeqIn),
			 true,lists:duplicate(2000, SeqIn),555555}),

    %% Test OTP-4590: correct encoding of the length of SEQUENC OF.
    DayNames = ["Monday","Tuesday","Wednesday",
		"Thursday","Friday","Saturday","Sunday"],
    xroundtrip('DayNames1', 'DayNames3', DayNames),
    xroundtrip('DayNames2', 'DayNames4', DayNames),
    xroundtrip('DayNames2', 'DayNames4', [hd(DayNames)]),
    xroundtrip('DayNames2', 'DayNames4', tl(DayNames)),

    ok.

roundtrip(T, V) ->
    roundtrip(T, V, V).

roundtrip(Type, Val, Expected) ->
    M = 'SeqOf',
    {ok,Enc} = M:encode(Type, Val),
    {ok,Expected} = M:decode(Type, Enc),
    ok.

xroundtrip(T1, T2, Val) ->
    M = 'XSeqOf',
    {ok,Enc} = M:encode(T1, Val),
    {ok,Enc} = M:encode(T2, Val),
    {ok,Val} = M:decode(T1, Enc),
    {ok,Val} = M:decode(T2, Enc),
    ok.
