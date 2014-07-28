###
## This file is part of Invenio.
## Copyright (C) 2014 CERN.
##
## Invenio is free software; you can redistribute it and/or
## modify it under the terms of the GNU General Public License as
## published by the Free Software Foundation; either version 2 of the
## License, or (at your option) any later version.
##
## Invenio is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Invenio; if not, write to the Free Software Foundation, Inc.,
## 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
###

class @InvenioConnector
	constructor: (@source) ->

	compileQuery: (queryArray) ->
		query = ''
		for clause in queryArray
			query += clause.operation + ' ' if clause.operation?
			query += clause.field + ':' if clause.field?
			query += clause.value + ' '

		return query.trim()
	
	performQuery: (query, callback) ->
		# TODO
		console.log "TODO: perform query '#{query}' on #{@source.name}"

		# For now, return sample data (from a search for "quarks" on the Invenio demo)
		sampleData = {
			lines: [
				{ field: 'authors', classes: 'authors', filter: 'joinList' },
				{ field: 'reportNumbers', classes: ['reportNumber', 'rightSide'] },
				{ field: 'date', filter: 'date' }
			],
			results: [
				{
					id: 55,
					title: "A new model-independent way of extracting |V_ub/V_cb|",
					authors: ["Aglietti, U", "Ciuchini, M", "Gambino, P"],
					reportNumbers: ["hep-ph/0204140"],
					date: "2014-05-21T10:01",
				},
				{
					id: 54,
					title: "Remarks on the f_0(400-1200) scalar meson as the dynamically generated chiral partner of the pion",
					authors: ["Van Beveren, E", "Kleefeld, F", "Rupp, G", "Scadron, M D"],
					reportNumbers: ["hep-ph/0204139"],
					date: "2014-05-21T10:01",
				},
				{
					id: 51,
					title: "Supersymmetry and a rationale for small CP violating phases",
					authors: ["Branco, G C", "Gomez, M E", "Khalil, S", "Teixeira, A M"],
					reportNumbers: ["hep-ph/0204136"],
					date: "2014-05-21T10:01",
				},
				{
					id: 47,
					title: "Thermal conductivity of dense quark matter and cooling of stars",
					authors: ["Shovkovy, I A", "Ellis, P J"],
					reportNumbers: ["hep-ph/0204132"],
					date: "2014-05-21T10:01",
				},
				{
					id: 13,
					title: "The total cross section for the production of heavy quarks in hadronic collisions",
					authors: ["Nason, P", "Dawson, S", "Ellis, R K"],
					reportNumbers: ["hep-ph/1234567"],
					date: "2014-05-21T10:01",
				},
				{
					id: 12,
					title: "Physics at the front-end of a neutrino factory : a quantitative appraisal",
					authors: ["Mangano, M L", "Alekhin, S I", "Anselmino, M", "Ball, R D", "Boglione, M", "D'Alesio, U", "Davidson, S", "De Lellis, G", "Ellis, J", "Forte, S", "Gambino, P", "Gehrmann, T", "Kataev, A L", "Kotzinian, A", "Kulagin, S A", "Lehmann-Dronke, B", "Migliozzi, P", "Murgia, F", "Ridolfi, G"],
					reportNumbers: ["hep-ph/0105155"],
					date: "2014-05-21T10:01",
				},
				{
					id: 1,
					title: "ALEPH experiment: Candidate of Higgs boson production",
					authors: ["Photolab"],
					reportNumbers: ["hep-ph/0987654"],
					date: "2014-05-21T10:01",
				},
			]
		}

		setTimeout((-> callback(sampleData)), 750)

	getRecord: (id, callback) ->
		# TODO
		console.log "TODO: get record #{id} from #{@source.name}"

		sampleRecord = {
			title: "A new model-independent way of extracting |V_ub/V_cb|"
			authors: [
				{name: "Aglietti, U.", inst: "CERN"}
				{name: "Ciuchini, M."}
				{name: "Gambino, P."}
			]
			journal: "CERN"
			date: '2002-04-12'  # ISO 8601
			reportNumbers: [ "CERN-TH-2002-069", "RM3-TH-02-4", "hep-ph/0204140" ]
			abstract: """
				The ratio between the photon spectrum in B -> X_s gamma and the
				differential semileptonic rate wrt the hadronic variable M_X/E_X is a
				short-distance quantity calculable in perturbation theory and independent
				of the Fermi motion of the b quark in the B meson. We present a NLO analysis
				of this ratio and show how it can be used to determine |V_ub/V_cb|
				independently of any model for the shape function. We also discuss how this
				relation can be used to test the validity of the shape-function theory on
				the data.
				"""
			keywords: [ "photon spectrum", "peturbation", "semileptonic rate" ]
		}

		setTimeout((-> callback(sampleRecord)), 750)

connectors = {
	invenio: InvenioConnector
}

@getConnector = (source) ->
	connectorClass = connectors[source.type ? 'invenio']
	if not connectorClass?
		# TODO: an error message
		console.error("No connector for source type #{source.type} is installed.")
		return

	return new connectorClass(source)
