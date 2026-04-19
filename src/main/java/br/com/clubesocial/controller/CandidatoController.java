package br.com.clubesocial.controller;

import br.com.clubesocial.model.Candidato;
import br.com.clubesocial.model.CandidatoStatus;
import br.com.clubesocial.service.CandidatoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("candidato")
public class CandidatoController {

    @Autowired
    private CandidatoService service;

    @GetMapping
    public List<Candidato> listar() {
        return service.listarTodos();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Candidato> buscarPorId(@PathVariable Long id) {
        return ResponseEntity.ok(service.buscarPorId(id));
    }

    @PostMapping
    public ResponseEntity<Candidato> criar(@RequestBody Candidato candidato) {
        return ResponseEntity.status(201).body(service.salvar(candidato));
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<Candidato> alterarStatus(@PathVariable Long id, @RequestBody CandidatoStatus status) {
        return ResponseEntity.ok(service.alterarStatus(id, status));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletar(@PathVariable Long id) {
        service.deletar(id);
        return ResponseEntity.noContent().build();
    }
}
