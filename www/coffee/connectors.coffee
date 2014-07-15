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
			lineStyles: ['authors', ['reportNumber', 'rightSide'], ''],
			records: [
				{
					id: 55,
					title: "A new model-independent way of extracting |V_ub/V_cb|",
					lines: ["Aglietti, U; Ciuchini, M; Gambino, P", "hep-ph/0204140", "21 May 2014, 10:01"],
				},
				{
					id: 54,
					title: "Remarks on the f_0(400-1200) scalar meson as the dynamically generated chiral partner of the pion",
					lines: ["Van Beveren, E; Kleefeld, F; Rupp, G; Scadron, M D", "hep-ph/0204139", "21 May 2014, 10:01"],
				},
				{
					id: 51,
					title: "Supersymmetry and a rationale for small CP violating phases",
					lines: ["Branco, G C; Gomez, M E; Khalil, S; Teixeira, A M", "hep-ph/0204136", "21 May 2014, 10:01"],
				},
				{
					id: 47,
					title: "Thermal conductivity of dense quark matter and cooling of stars",
					lines: ["Shovkovy, I A; Ellis, P J", "hep-ph/0204132", "21 May 2014, 10:01"],
				},
				{
					id: 13,
					title: "The total cross section for the production of heavy quarks in hadronic collisions",
					lines: ["Nason, P; Dawson, S; Ellis, R K", "hep-ph/1234567", "21 May 2014, 10:01"],
				},
				{
					id: 12,
					title: "Physics at the front-end of a neutrino factory : a quantitative appraisal",
					lines: ["Mangano, M L; Alekhin, S I; Anselmino, M; Ball, R D; Boglione, M; D'Alesio, U; Davidson, S; De Lellis, G; Ellis, J; Forte, S; Gambino, P; Gehrmann, T; Kataev, A L; Kotzinian, A; Kulagin, S A; Lehmann-Dronke, B; Migliozzi, P; Murgia, F; Ridolfi, G", "hep-ph/0105155", "21 May 2014, 10:01"],
				},
				{
					id: 1,
					title: "ALEPH experiment: Candidate of Higgs boson production",
					lines: ["Photolab", "hep-ph/0987654", "21 May 2014, 10:01"],
				},
			]
		}

		setTimeout((-> callback(sampleData)), 750)

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
